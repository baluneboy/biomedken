// Copyright © Microsoft Corporation.  All Rights Reserved.
// This code released under the terms of the 
// Microsoft Public License (MS-PL, http://opensource.org/licenses/ms-pl.html.)

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Microsoft.Office.Tools.Excel;
using Microsoft.Office.Tools.Excel.Extensions;
using Excel = Microsoft.Office.Interop.Excel;
using Microsoft.Office.Tools;

namespace ExcelAddInDynamicControls
{
    public partial class ThisAddIn
    {
        ControlSelector _selector;
        CustomTaskPane _selectorPane;

        private void ThisAddIn_Startup(object sender, System.EventArgs e)
        {
            _selector = new ControlSelector();
            _selectorPane = this.CustomTaskPanes.Add(_selector, "Control Selector");
            _selectorPane.Visible = true;
            _selectorPane.Width = 250;

            this.Application.WorkbookOpen += new Excel.AppEvents_WorkbookOpenEventHandler(Application_WorkbookOpen);
            this.Application.WorkbookBeforeSave += new Excel.AppEvents_WorkbookBeforeSaveEventHandler(Application_WorkbookBeforeSave);
            this.Application.WorkbookActivate += new Excel.AppEvents_WorkbookActivateEventHandler(Application_WorkbookActivate);
        }

        void Application_WorkbookActivate(Excel.Workbook workbook)
        {
            Excel.Worksheet worksheetInteropObject = workbook.Worksheets[1] as Excel.Worksheet;

            _selector.SetWorksheet(worksheetInteropObject);
            if (worksheetInteropObject != null && Globals.Factory.HasVstoObject(worksheetInteropObject))
            {
                Worksheet vstoWorksheet = Globals.Factory.GetVstoObject(worksheetInteropObject);
                RefreshControlSelector(vstoWorksheet);
            }
            else
            {
                RefreshControlSelector(null);
            }
        }

        void Application_WorkbookOpen(Excel.Workbook workbook)
        {
            // Load the persisted state of dynamic controls.
            ControlProperties[] savedControls = ControlsStorage.Load(workbook);

            if (savedControls != null && savedControls.Length > 0)
            {
                Worksheet vstoWorksheet = (Globals.Factory.GetVstoObject((Excel.Worksheet)workbook.Worksheets[1]));

                // Recreate controls according to persisted state.
                foreach (ControlProperties controlInfo in savedControls)
                {
                    Type t = null;

                    // We create Windows Forms controls by instantiating their type.
                    // For host controls (which do not have a default constructor), we call
                    // specific methods, e.g. AddListObject().
                    switch (controlInfo.ControlType)
                    {
                        case ControlProperties.DynamicControlType.Button:
                            t = typeof(Button);
                            break;
                        case ControlProperties.DynamicControlType.RadioButton:
                            t = typeof(RadioButton);
                            break;
                        case ControlProperties.DynamicControlType.CheckBox:
                            t = typeof(CheckBox);
                            break;
                        case ControlProperties.DynamicControlType.ComboBox:
                            t = typeof(ComboBox);
                            break;
                        case ControlProperties.DynamicControlType.UserControl:
                            t = typeof(RadioButtonSet);
                            break;
                        case ControlProperties.DynamicControlType.NamedRangeImpl:
                            vstoWorksheet.Controls.AddNamedRange(vstoWorksheet.Range[controlInfo.ControlAddress, missing], controlInfo.ControlName);
                            break;
                        case ControlProperties.DynamicControlType.ListObjectImpl:
                            Excel.ListObject list = vstoWorksheet.ListObjects.get_Item(controlInfo.ControlName);
                            if (list != null)
                            {
                                // This adds the ListObject into the Worksheet.Controls collection.
                                Globals.Factory.GetVstoObject(list);
                            }
                            break;
                        default:
                            break;
                    }

                    // If it is a known Windows Forms controlInfo type,
                    // instantiate it, restore any persisted properties 
                    // and insert it into the sheet.
                    if (t != null)
                    {
                        Control control = (Control)Activator.CreateInstance(t);

                        // Restore the name.
                        control.Name = controlInfo.ControlName;

                        if (controlInfo.ControlType == ControlProperties.DynamicControlType.ComboBox)
                        {
                            SetComboBoxProperties(controlInfo, (ComboBox)control);
                        }
                        else if (controlInfo.ControlType == ControlProperties.DynamicControlType.CheckBox)
                        {
                            SetCheckBoxProperties(controlInfo, (CheckBox)control);
                        }

                        Microsoft.Office.Tools.Excel.ControlSite wrapped = vstoWorksheet.Controls.AddControl(control,
                            controlInfo.ControlX,
                            controlInfo.ControlY,
                            controlInfo.ControlWidth,
                            controlInfo.ControlHeight,
                            controlInfo.ControlName);

                        SetPlacement(controlInfo, wrapped);
                        control.Tag = wrapped;
                    }

                    RefreshControlSelector(vstoWorksheet);
                }
            }
        }

        private void Application_WorkbookBeforeSave(Excel.Workbook workbook, bool SaveAsUI, ref bool Cancel)
        {
            Excel.Worksheet worksheetInteropObject = workbook.Worksheets[1] as Excel.Worksheet;

            if (Globals.Factory.HasVstoObject(worksheetInteropObject))
            {
                Worksheet vstoWorksheet = Globals.Factory.GetVstoObject(worksheetInteropObject);
                bool save = false;
                DialogResult result = DialogResult.Yes;
                List<object> controlsToRemove = new List<object>();
                List<ControlProperties> savedControls = new List<ControlProperties>();

                if (vstoWorksheet.Controls.Count > 0)
                {
                    result = MessageBox.Show(
                        "You have added contols to the document surface, that might not be visible on other computers.  Do you want to delete them before saving the document?",
                        "Delete controls?",
                        MessageBoxButtons.YesNoCancel,
                        MessageBoxIcon.Question);

                    if (result == DialogResult.Yes)
                    {
                        save = false;
                    }
                    else if (result == DialogResult.No)
                    {
                        save = true;
                    }
                    else if (result == DialogResult.Cancel)
                    {
                        Cancel = true;
                        return;
                    }

                    for (int i = 0; i < vstoWorksheet.Controls.Count; i++)
                    {
                        object vstoControl = vstoWorksheet.Controls[i];

                        if (save)
                        {
                           
                            string typeName = vstoControl.GetType().Name;
                            
                            ControlProperties.DynamicControlType type = TypeFromTypeName(typeName);

                            Control winFormsControl = vstoControl as Control;

                            Microsoft.Office.Tools.Excel.NamedRange range;
                            Microsoft.Office.Tools.Excel.ListObject list;

                            if (winFormsControl != null)
                            {
                                // We need to access some extended ptoperties (such as Top or Width, for example).
                                // The Object for the controls should be stored in the controls' Tag property.
                                Microsoft.Office.Tools.Excel.ControlSite extender = (Microsoft.Office.Tools.Excel.ControlSite)winFormsControl.Tag;

                                savedControls.Add(
                                    new ControlProperties(
                                        winFormsControl.Name,
                                        type,
                                        extender.Left,
                                        extender.Top,
                                        extender.Width,
                                        extender.Height,
                                        GetPersistentProperties(winFormsControl)));
                            }
                            else if ((range = vstoControl as Microsoft.Office.Tools.Excel.NamedRange) != null)
                            {
                                savedControls.Add(new ControlProperties(range.Tag.ToString(), type, range.RefersTo));
                            }
                            else if ((list = vstoControl as Microsoft.Office.Tools.Excel.ListObject) != null)
                            {
                                savedControls.Add(new ControlProperties(
                                    list.Name,
                                    type,
                                    list.Range.get_Address(
                                    true,
                                    true,
                                    Microsoft.Office.Interop.Excel.XlReferenceStyle.xlA1,
                                    missing,
                                    missing)));
                            }
                        }
                        else
                        {
                            controlsToRemove.Add(vstoControl);
                        }
                    }
                }

                ControlsStorage.Store(workbook, savedControls.ToArray());

                foreach (object control in controlsToRemove)
                {
                    vstoWorksheet.Controls.Remove(control);
                }

                RefreshControlSelector(vstoWorksheet);
            }
        }

        private void RefreshControlSelector(Worksheet worksheet)
        {
            _selector.CheckButton.Checked = false;
            _selector.CheckRadio.Checked = false;
            _selector.CheckCheck.Checked = false;
            _selector.CheckCombo.Checked = false;
            _selector.CheckUser.Checked = false;
            _selector.CheckList.Checked = false;
            _selector.CheckNamed.Checked = false;

            if (worksheet != null)
            {
                foreach (object control in worksheet.Controls)
                {
                    CheckBox selectorBox = null;

                    if (control is Button)
                        selectorBox = _selector.CheckButton;
                    else if (control is RadioButton)
                        selectorBox = _selector.CheckRadio;
                    else if (control is CheckBox)
                        selectorBox = _selector.CheckCheck;
                    else if (control is ComboBox)
                        selectorBox = _selector.CheckCombo;
                    else if (control is RadioButtonSet)
                        selectorBox = _selector.CheckUser;
                    else if (control is ListObject)
                        selectorBox = _selector.CheckList;
                    else if (control is NamedRange)
                        selectorBox = _selector.CheckNamed;

                    if (selectorBox != null)
                    {
                        selectorBox.Checked = true;
                    }
                }
            }
        }

        private static KeyValuePair<string, object>[] GetPersistentProperties(Control vstoControl)
        {
            List<KeyValuePair<string, object>> list = new List<KeyValuePair<string, object>>();

            ComboBox combo;
            CheckBox check;

            if ((combo = vstoControl as ComboBox) != null)
            {
                List<string> itemList = new List<string>(combo.Items.Count);

                foreach (object item in combo.Items)
                {
                    itemList.Add(item.ToString());
                }

                list.Add(new KeyValuePair<string, object>("Items", string.Join("\n", itemList.ToArray())));
                list.Add(new KeyValuePair<string, object>("SelectedIndex", combo.SelectedIndex));
            }
            else if ((check = vstoControl as CheckBox) != null)
            {
                list.Add(new KeyValuePair<string, object>("Checked", check.Checked));
            }

            Excel._OLEObject oleObject = vstoControl as Excel._OLEObject;
            if (oleObject != null)
            {
                list.Add(new KeyValuePair<string, object>("Placement", (Excel.XlPlacement)oleObject.Placement));
            }
            else
            {
                Microsoft.Office.Tools.Excel.ControlSite extender = (Microsoft.Office.Tools.Excel.ControlSite)vstoControl.Tag;

                list.Add(new KeyValuePair<string, object>("Placement", (Excel.XlPlacement)extender.Placement));
            }

            return list.ToArray();
        }

        private static ControlProperties.DynamicControlType TypeFromTypeName(string typeName)
        {
            string shortName = typeName.Substring(typeName.LastIndexOf('.') + 1);

            if (shortName == "RadioButtonSet")
            {
                return ControlProperties.DynamicControlType.UserControl;
            }
            else
            {
                return (ControlProperties.DynamicControlType)Enum.Parse(typeof(ControlProperties.DynamicControlType), shortName);
            }
        }

        private static void SetComboBoxProperties(ControlProperties properties, ComboBox c)
        {
            foreach (KeyValuePair<string, object> pair in properties.PropertyList)
            {
                if (pair.Key == "Items")
                {
                    c.Items.AddRange(((string)pair.Value).Split('\n'));

                }
                else if (pair.Key == "SelectedIndex")
                {
                    c.SelectedIndex = (int)pair.Value;
                }
            }
        }

        private static void SetCheckBoxProperties(ControlProperties properties, CheckBox c)
        {
            foreach (KeyValuePair<string, object> pair in properties.PropertyList)
            {
                if (pair.Key == "Checked")
                {
                    c.Checked = (bool)pair.Value;
                    break;
                }
            }
        }

        private static void SetPlacement(ControlProperties properties, Microsoft.Office.Tools.Excel.ControlSite control)
        {
            foreach (KeyValuePair<string, object> pair in properties.PropertyList)
            {
                if (pair.Key == "Placement")
                {
                    control.Placement = (Excel.XlPlacement)pair.Value;
                    break;
                }
            }
        }

        #region VSTO generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(ThisAddIn_Startup);
        }
        
        #endregion  
    }
}
