namespace CrayonAutomaton {
    partial class enterTextDialog {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.selectFontButton = new System.Windows.Forms.Button();
            this.fontLabel = new System.Windows.Forms.Label();
            this.usersText = new System.Windows.Forms.TextBox();
            this.cancelButton = new System.Windows.Forms.Button();
            this.okButton = new System.Windows.Forms.Button();
            this.previewCheckBox = new System.Windows.Forms.CheckBox();
            this.symbolButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // selectFontButton
            // 
            this.selectFontButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.selectFontButton.Location = new System.Drawing.Point(578, 15);
            this.selectFontButton.Name = "selectFontButton";
            this.selectFontButton.Size = new System.Drawing.Size(25, 20);
            this.selectFontButton.TabIndex = 0;
            this.selectFontButton.Text = "...";
            this.selectFontButton.UseVisualStyleBackColor = true;
            this.selectFontButton.Click += new System.EventHandler(this.selectFontButton_Click);
            // 
            // fontLabel
            // 
            this.fontLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.fontLabel.AutoEllipsis = true;
            this.fontLabel.Location = new System.Drawing.Point(12, 15);
            this.fontLabel.Name = "fontLabel";
            this.fontLabel.Size = new System.Drawing.Size(560, 20);
            this.fontLabel.TabIndex = 1;
            this.fontLabel.Text = "label1";
            // 
            // usersText
            // 
            this.usersText.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.usersText.Location = new System.Drawing.Point(12, 38);
            this.usersText.Multiline = true;
            this.usersText.Name = "usersText";
            this.usersText.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.usersText.Size = new System.Drawing.Size(591, 255);
            this.usersText.TabIndex = 2;
            // 
            // cancelButton
            // 
            this.cancelButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(415, 299);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(91, 30);
            this.cancelButton.TabIndex = 3;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // okButton
            // 
            this.okButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.okButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.okButton.Location = new System.Drawing.Point(512, 299);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(91, 30);
            this.okButton.TabIndex = 4;
            this.okButton.Text = "Ok";
            this.okButton.UseVisualStyleBackColor = true;
            // 
            // previewCheckBox
            // 
            this.previewCheckBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.previewCheckBox.AutoSize = true;
            this.previewCheckBox.Checked = true;
            this.previewCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.previewCheckBox.Location = new System.Drawing.Point(92, 307);
            this.previewCheckBox.Name = "previewCheckBox";
            this.previewCheckBox.Size = new System.Drawing.Size(87, 17);
            this.previewCheckBox.TabIndex = 6;
            this.previewCheckBox.Text = "Live Preview";
            this.previewCheckBox.UseVisualStyleBackColor = true;
            this.previewCheckBox.CheckedChanged += new System.EventHandler(this.previewCheckBox_CheckedChanged);
            // 
            // symbolButton
            // 
            this.symbolButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.symbolButton.Location = new System.Drawing.Point(12, 299);
            this.symbolButton.Name = "symbolButton";
            this.symbolButton.Size = new System.Drawing.Size(74, 30);
            this.symbolButton.TabIndex = 7;
            this.symbolButton.Text = "Add Symbol";
            this.symbolButton.UseVisualStyleBackColor = true;
            this.symbolButton.Click += new System.EventHandler(this.symbolButton_Click);
            // 
            // enterTextDialog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(615, 341);
            this.Controls.Add(this.symbolButton);
            this.Controls.Add(this.previewCheckBox);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.usersText);
            this.Controls.Add(this.fontLabel);
            this.Controls.Add(this.selectFontButton);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.Name = "enterTextDialog";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Add String";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button selectFontButton;
        private System.Windows.Forms.Label fontLabel;
        private System.Windows.Forms.TextBox usersText;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.CheckBox previewCheckBox;
        private System.Windows.Forms.Button symbolButton;
    }
}