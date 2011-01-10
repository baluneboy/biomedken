namespace ExcelAutomationClient
{
    partial class Form1
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.buttonCreateDummyData = new System.Windows.Forms.Button();
            this.buttonReadExistingData = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // buttonCreateDummyData
            // 
            this.buttonCreateDummyData.Location = new System.Drawing.Point(31, 58);
            this.buttonCreateDummyData.Name = "buttonCreateDummyData";
            this.buttonCreateDummyData.Size = new System.Drawing.Size(132, 23);
            this.buttonCreateDummyData.TabIndex = 0;
            this.buttonCreateDummyData.Text = "CreateDummyData";
            this.buttonCreateDummyData.UseVisualStyleBackColor = true;
            this.buttonCreateDummyData.Click += new System.EventHandler(this.buttonCreateDummyData_Click);
            // 
            // buttonReadExistingData
            // 
            this.buttonReadExistingData.Location = new System.Drawing.Point(31, 87);
            this.buttonReadExistingData.Name = "buttonReadExistingData";
            this.buttonReadExistingData.Size = new System.Drawing.Size(132, 23);
            this.buttonReadExistingData.TabIndex = 1;
            this.buttonReadExistingData.Text = "ReadExistingData";
            this.buttonReadExistingData.UseVisualStyleBackColor = true;
            this.buttonReadExistingData.Click += new System.EventHandler(this.buttonReadExistingData_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(195, 136);
            this.Controls.Add(this.buttonReadExistingData);
            this.Controls.Add(this.buttonCreateDummyData);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button buttonCreateDummyData;
        private System.Windows.Forms.Button buttonReadExistingData;
    }
}

