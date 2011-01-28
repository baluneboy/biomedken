namespace CrayonAutomaton {
    partial class textSymbol {
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
            this.largeSymbolLabel = new System.Windows.Forms.Label();
            this.addedSymbolsText = new System.Windows.Forms.TextBox();
            this.okButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.housingPanel = new System.Windows.Forms.Panel();
            this.symbolBox = new System.Windows.Forms.PictureBox();
            this.charInfoLabel = new System.Windows.Forms.Label();
            this.housingPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.symbolBox)).BeginInit();
            this.SuspendLayout();
            // 
            // largeSymbolLabel
            // 
            this.largeSymbolLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.largeSymbolLabel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.largeSymbolLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.largeSymbolLabel.Location = new System.Drawing.Point(12, 321);
            this.largeSymbolLabel.Name = "largeSymbolLabel";
            this.largeSymbolLabel.Size = new System.Drawing.Size(60, 51);
            this.largeSymbolLabel.TabIndex = 0;
            this.largeSymbolLabel.Text = "A";
            this.largeSymbolLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // addedSymbolsText
            // 
            this.addedSymbolsText.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.addedSymbolsText.Location = new System.Drawing.Point(78, 321);
            this.addedSymbolsText.Name = "addedSymbolsText";
            this.addedSymbolsText.Size = new System.Drawing.Size(426, 20);
            this.addedSymbolsText.TabIndex = 1;
            // 
            // okButton
            // 
            this.okButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.okButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.okButton.Location = new System.Drawing.Point(429, 349);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(75, 23);
            this.okButton.TabIndex = 2;
            this.okButton.Text = "Ok";
            this.okButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(348, 349);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(75, 23);
            this.cancelButton.TabIndex = 3;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // housingPanel
            // 
            this.housingPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.housingPanel.AutoScroll = true;
            this.housingPanel.Controls.Add(this.symbolBox);
            this.housingPanel.Location = new System.Drawing.Point(12, 12);
            this.housingPanel.Name = "housingPanel";
            this.housingPanel.Size = new System.Drawing.Size(492, 303);
            this.housingPanel.TabIndex = 4;
            // 
            // symbolBox
            // 
            this.symbolBox.BackColor = System.Drawing.Color.White;
            this.symbolBox.Location = new System.Drawing.Point(0, 0);
            this.symbolBox.Name = "symbolBox";
            this.symbolBox.Size = new System.Drawing.Size(492, 45);
            this.symbolBox.TabIndex = 0;
            this.symbolBox.TabStop = false;
            // 
            // charInfoLabel
            // 
            this.charInfoLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.charInfoLabel.AutoSize = true;
            this.charInfoLabel.Location = new System.Drawing.Point(78, 353);
            this.charInfoLabel.Name = "charInfoLabel";
            this.charInfoLabel.Size = new System.Drawing.Size(0, 13);
            this.charInfoLabel.TabIndex = 5;
            // 
            // textSymbol
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(516, 381);
            this.Controls.Add(this.charInfoLabel);
            this.Controls.Add(this.housingPanel);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.addedSymbolsText);
            this.Controls.Add(this.largeSymbolLabel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.MaximumSize = new System.Drawing.Size(532, 99999);
            this.MinimumSize = new System.Drawing.Size(532, 34);
            this.Name = "textSymbol";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Add Symbols";
            this.housingPanel.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.symbolBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label largeSymbolLabel;
        private System.Windows.Forms.TextBox addedSymbolsText;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Panel housingPanel;
        private System.Windows.Forms.PictureBox symbolBox;
        private System.Windows.Forms.Label charInfoLabel;
    }
}