namespace ExcelAddInDynamicControls
{
    partial class ControlSelector
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.CheckCheck = new System.Windows.Forms.CheckBox();
            this.CheckCombo = new System.Windows.Forms.CheckBox();
            this.CheckUser = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.CheckList = new System.Windows.Forms.CheckBox();
            this.CheckNamed = new System.Windows.Forms.CheckBox();
            this.CheckRadio = new System.Windows.Forms.CheckBox();
            this.CheckButton = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // CheckCheck
            // 
            this.CheckCheck.AutoSize = true;
            this.CheckCheck.Location = new System.Drawing.Point(35, 128);
            this.CheckCheck.Name = "CheckCheck";
            this.CheckCheck.Size = new System.Drawing.Size(78, 17);
            this.CheckCheck.TabIndex = 1;
            this.CheckCheck.Text = "Check Box";
            this.CheckCheck.Click += new System.EventHandler(this.CheckCheck_Click);
            // 
            // CheckCombo
            // 
            this.CheckCombo.AutoSize = true;
            this.CheckCombo.Location = new System.Drawing.Point(35, 162);
            this.CheckCombo.Name = "CheckCombo";
            this.CheckCombo.Size = new System.Drawing.Size(80, 17);
            this.CheckCombo.TabIndex = 2;
            this.CheckCombo.Text = "Combo Box";
            this.CheckCombo.Click += new System.EventHandler(this.CheckCombo_Click);
            // 
            // CheckUser
            // 
            this.CheckUser.AutoSize = true;
            this.CheckUser.Location = new System.Drawing.Point(35, 230);
            this.CheckUser.Name = "CheckUser";
            this.CheckUser.Size = new System.Drawing.Size(122, 17);
            this.CheckUser.TabIndex = 4;
            this.CheckUser.Text = "Custom User Control";
            this.CheckUser.Click += new System.EventHandler(this.CheckUser_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(35, 34);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(188, 52);
            this.label1.TabIndex = 5;
            this.label1.Text = "Select a check box to add a Windows\r\nForms control to the currently\r\nselected cel" +
                "ls on the worksheet. Clear\r\na check box to remove the control.";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(30, 255);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(176, 52);
            this.label2.TabIndex = 6;
            this.label2.Text = "Select a check box to add an Excel\r\ncontrol to the currently selected\r\ncells on t" +
                "he worksheet. Clear a\r\ncheck box to remove the control.";
            // 
            // CheckList
            // 
            this.CheckList.AutoSize = true;
            this.CheckList.Location = new System.Drawing.Point(35, 358);
            this.CheckList.Name = "CheckList";
            this.CheckList.Size = new System.Drawing.Size(76, 17);
            this.CheckList.TabIndex = 8;
            this.CheckList.Text = "List Object";
            this.CheckList.Click += new System.EventHandler(this.CheckList_Click);
            // 
            // CheckNamed
            // 
            this.CheckNamed.AutoSize = true;
            this.CheckNamed.Location = new System.Drawing.Point(35, 317);
            this.CheckNamed.Name = "CheckNamed";
            this.CheckNamed.Size = new System.Drawing.Size(95, 17);
            this.CheckNamed.TabIndex = 7;
            this.CheckNamed.Text = "Named Range";
            this.CheckNamed.Click += new System.EventHandler(this.CheckNamed_Click);
            // 
            // CheckRadio
            // 
            this.CheckRadio.AutoSize = true;
            this.CheckRadio.Location = new System.Drawing.Point(35, 196);
            this.CheckRadio.Name = "CheckRadio";
            this.CheckRadio.Size = new System.Drawing.Size(88, 17);
            this.CheckRadio.TabIndex = 3;
            this.CheckRadio.Text = "Radio Button";
            this.CheckRadio.Click += new System.EventHandler(this.CheckRadio_Click);
            // 
            // CheckButton
            // 
            this.CheckButton.AutoSize = true;
            this.CheckButton.Location = new System.Drawing.Point(35, 94);
            this.CheckButton.Name = "CheckButton";
            this.CheckButton.Size = new System.Drawing.Size(57, 17);
            this.CheckButton.TabIndex = 0;
            this.CheckButton.Text = "Button";
            this.CheckButton.Click += new System.EventHandler(this.CheckButton_Click);
            // 
            // ControlSelector
            // 
            this.Controls.Add(this.CheckList);
            this.Controls.Add(this.CheckNamed);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.CheckUser);
            this.Controls.Add(this.CheckRadio);
            this.Controls.Add(this.CheckCombo);
            this.Controls.Add(this.CheckButton);
            this.Controls.Add(this.CheckCheck);
            this.Name = "ControlSelector";
            this.Size = new System.Drawing.Size(255, 563);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        internal System.Windows.Forms.CheckBox CheckUser;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        internal System.Windows.Forms.CheckBox CheckCheck;
        internal System.Windows.Forms.CheckBox CheckCombo;
        internal System.Windows.Forms.CheckBox CheckList;
        internal System.Windows.Forms.CheckBox CheckNamed;
        internal System.Windows.Forms.CheckBox CheckRadio;
        internal System.Windows.Forms.CheckBox CheckButton;
    }
}
