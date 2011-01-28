// Copyright © Microsoft Corporation.  All Rights Reserved.
// This code released under the terms of the 
// Microsoft Public License (MS-PL, http://opensource.org/licenses/ms-pl.html.)

using System;
using System.Windows.Forms;
using Microsoft.Office.Tools.Excel;
using Microsoft.Office.Tools.Excel.Extensions;
using Excel = Microsoft.Office.Interop.Excel;

namespace ExcelAddInDynamicControls
{
    public partial class ControlSelector : UserControl
    {
        Worksheet _vstoWorkSheet;
        Excel.Worksheet _worksheetInteropObject;

        public Worksheet VstoWorksheet
        {
            get
            {
                if (_vstoWorkSheet == null)
                {
                    if (_worksheetInteropObject == null)
                    {
                        _vstoWorkSheet = Globals.Factory.GetVstoObject(((Excel.Worksheet)Globals.ThisAddIn.Application.ActiveWorkbook.Worksheets[1]));
                    }
                    else
                    {
                        _vstoWorkSheet = Globals.Factory.GetVstoObject(_worksheetInteropObject);
                    }
                }

                _vstoWorkSheet.Activate();
                return _vstoWorkSheet;
            }
        }

        public void SetWorksheet(Excel.Worksheet worksheetInteropObject)
        {
            _worksheetInteropObject = worksheetInteropObject;
            _vstoWorkSheet = null;
        }

        public ControlSelector()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Inserts a button named MyButton if no such control
        /// exists in the document; otherwise, removes the existing control.
        /// </summary>
        /// <param name="sender">The sender of the message (check box).</param>
        /// <param name="e">Event arguments.</param>
        private void CheckButton_Click(object sender, EventArgs e)
        {
            string name = "MyButton";
            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    Microsoft.Office.Tools.Excel.Controls.Button control = new Microsoft.Office.Tools.Excel.Controls.Button();
                    control.Tag = VstoWorksheet.Controls.AddControl(control, selection, name);
                    control.Name = name;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        /// <summary>
        /// Inserts a check box named MyCheckBox if no such control
        /// exists in the document; otherwise, removes the existing control.
        /// </summary>
        /// <param name="sender">The sender of the message (check box).</param>
        /// <param name="e">Event arguments.</param>
        private void CheckCheck_Click(object sender, EventArgs e)
        {
            string name = "MyCheckBox";

            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    Microsoft.Office.Tools.Excel.Controls.CheckBox control = new Microsoft.Office.Tools.Excel.Controls.CheckBox();
                    control.Tag = VstoWorksheet.Controls.AddControl(control, selection, name);
                    control.Name = name;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        /// <summary>
        /// Inserts a radio button named MyRadioButton if no such control
        /// exists in the document; otherwise, removes the existing control.
        /// </summary>
        /// <param name="sender">The sender of the message (check box).</param>
        /// <param name="e">Event arguments.</param>
        private void CheckRadio_Click(object sender, EventArgs e)
        {
            string name = "MyRadioButton";

            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    Microsoft.Office.Tools.Excel.Controls.RadioButton control = new Microsoft.Office.Tools.Excel.Controls.RadioButton();
                    control.Tag = VstoWorksheet.Controls.AddControl(control, selection, name);
                    control.Name = name;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        /// <summary>
        /// Inserts a combo box named MyComboBox if no such control
        /// exists in the document; otherwise, removes the existing control.
        /// </summary>
        /// <param name="sender">The sender of the message (check box).</param>
        /// <param name="e">Event arguments.</param>
        private void CheckCombo_Click(object sender, EventArgs e)
        {
            string name = "MyComboBox";

            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    Microsoft.Office.Tools.Excel.Controls.ComboBox control = new Microsoft.Office.Tools.Excel.Controls.ComboBox();
                    control.Tag = VstoWorksheet.Controls.AddControl(control, selection, name);
                    control.Name = name;
                    control.Items.AddRange(new object[] { "Item 1", "Item 2", "Item 3" });
                    control.SelectedIndex = 1;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        private void CheckNamed_Click(object sender, EventArgs e)
        {
            string name = "MyNamedRange";

            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    NamedRange namedRange = VstoWorksheet.Controls.AddNamedRange(selection, name);
                    namedRange.Tag = name;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        private void CheckList_Click(object sender, EventArgs e)
        {
            string name = "MyListObject";
            
            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    VstoWorksheet.Controls.AddListObject(selection, name);
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }


        /// <summary>
        /// Inserts a RadioButtonSet user control named MyUserControl if no such control
        /// exists in the document; otherwise, removes the existing control.
        /// </summary>
        /// <param name="sender">The sender of the message (check box).</param>
        /// <param name="e">Event arguments.</param>
        private void CheckUser_Click(object sender, EventArgs e)
        {
            string name = "MyUserControl";

            if (((CheckBox)sender).Checked)
            {
                Excel.Range selection = SelectedRange;

                if (selection != null)
                {
                    RadioButtonSet control = new RadioButtonSet();
                    control.Tag = VstoWorksheet.Controls.AddControl(control, selection, name);
                    control.Name = name;
                }
            }
            else
            {
                VstoWorksheet.Controls.Remove(name);
            }
        }

        private Excel.Range SelectedRange
        {
            get
            {
                Excel.Range selection = VstoWorksheet.Application.Selection as Excel.Range;

                if (selection != null &&
                    selection.Worksheet.Name == VstoWorksheet.Name)
                {
                    return selection;
                }

                return null;
            }
        }
    }
}
