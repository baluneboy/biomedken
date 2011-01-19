namespace WinAppMyGlob
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
            this.btnGlob = new System.Windows.Forms.Button();
            this.clbFiles = new System.Windows.Forms.CheckedListBox();
            this.txtGlobPattern = new System.Windows.Forms.TextBox();
            this.btnValidate = new System.Windows.Forms.Button();
            this.btnSelectAll = new System.Windows.Forms.Button();
            this.btnUnselectAll = new System.Windows.Forms.Button();
            this.btnProcess = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnGlob
            // 
            this.btnGlob.Font = new System.Drawing.Font("MS Reference Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnGlob.Location = new System.Drawing.Point(12, 17);
            this.btnGlob.Name = "btnGlob";
            this.btnGlob.Size = new System.Drawing.Size(57, 32);
            this.btnGlob.TabIndex = 0;
            this.btnGlob.Text = "Glob";
            this.btnGlob.UseCompatibleTextRendering = true;
            this.btnGlob.UseVisualStyleBackColor = true;
            this.btnGlob.Click += new System.EventHandler(this.btnGlob_Click);
            // 
            // clbFiles
            // 
            this.clbFiles.Font = new System.Drawing.Font("MS Reference Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clbFiles.FormattingEnabled = true;
            this.clbFiles.Location = new System.Drawing.Point(142, 57);
            this.clbFiles.Name = "clbFiles";
            this.clbFiles.Size = new System.Drawing.Size(1103, 460);
            this.clbFiles.TabIndex = 1;
            this.clbFiles.UseCompatibleTextRendering = true;
            this.clbFiles.DataSourceChanged += new System.EventHandler(this.clbFiles_DataSourceChanged);
            this.clbFiles.SelectedIndexChanged += new System.EventHandler(this.clbFiles_SelectedIndexChanged);
            // 
            // txtGlobPattern
            // 
            this.txtGlobPattern.Font = new System.Drawing.Font("MS Reference Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel, ((byte)(0)));
            this.txtGlobPattern.Location = new System.Drawing.Point(75, 19);
            this.txtGlobPattern.Name = "txtGlobPattern";
            this.txtGlobPattern.Size = new System.Drawing.Size(1170, 22);
            this.txtGlobPattern.TabIndex = 2;
            this.txtGlobPattern.Text = "c:\\temp\\dupstination\\t*o\\tra*.txt";
            this.txtGlobPattern.TextChanged += new System.EventHandler(this.txtGlobPattern_TextChanged);
            // 
            // btnValidate
            // 
            this.btnValidate.Font = new System.Drawing.Font("MS Reference Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnValidate.Location = new System.Drawing.Point(12, 57);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(124, 33);
            this.btnValidate.TabIndex = 3;
            this.btnValidate.Text = "Validate";
            this.btnValidate.UseCompatibleTextRendering = true;
            this.btnValidate.UseVisualStyleBackColor = true;
            this.btnValidate.Click += new System.EventHandler(this.btnValidate_Click);
            // 
            // btnSelectAll
            // 
            this.btnSelectAll.Font = new System.Drawing.Font("MS Reference Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSelectAll.Location = new System.Drawing.Point(12, 455);
            this.btnSelectAll.Name = "btnSelectAll";
            this.btnSelectAll.Size = new System.Drawing.Size(124, 28);
            this.btnSelectAll.TabIndex = 4;
            this.btnSelectAll.Text = "select all";
            this.btnSelectAll.UseCompatibleTextRendering = true;
            this.btnSelectAll.UseVisualStyleBackColor = true;
            this.btnSelectAll.Click += new System.EventHandler(this.btnSelectAll_Click);
            // 
            // btnUnselectAll
            // 
            this.btnUnselectAll.Font = new System.Drawing.Font("MS Reference Sans Serif", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnUnselectAll.Location = new System.Drawing.Point(12, 489);
            this.btnUnselectAll.Name = "btnUnselectAll";
            this.btnUnselectAll.Size = new System.Drawing.Size(124, 28);
            this.btnUnselectAll.TabIndex = 5;
            this.btnUnselectAll.Text = "unselect all";
            this.btnUnselectAll.UseCompatibleTextRendering = true;
            this.btnUnselectAll.UseVisualStyleBackColor = true;
            this.btnUnselectAll.Click += new System.EventHandler(this.btnUnselectAll_Click);
            // 
            // btnProcess
            // 
            this.btnProcess.Enabled = false;
            this.btnProcess.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnProcess.Location = new System.Drawing.Point(12, 96);
            this.btnProcess.Name = "btnProcess";
            this.btnProcess.Size = new System.Drawing.Size(124, 33);
            this.btnProcess.TabIndex = 6;
            this.btnProcess.Text = "PROCESS";
            this.btnProcess.UseVisualStyleBackColor = true;
            this.btnProcess.Click += new System.EventHandler(this.btnProcess_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1289, 565);
            this.Controls.Add(this.btnProcess);
            this.Controls.Add(this.btnUnselectAll);
            this.Controls.Add(this.btnSelectAll);
            this.Controls.Add(this.btnValidate);
            this.Controls.Add(this.txtGlobPattern);
            this.Controls.Add(this.clbFiles);
            this.Controls.Add(this.btnGlob);
            this.Location = new System.Drawing.Point(0, 11);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnGlob;
        private System.Windows.Forms.CheckedListBox clbFiles;
        private System.Windows.Forms.TextBox txtGlobPattern;
        private System.Windows.Forms.Button btnValidate;
        private System.Windows.Forms.Button btnSelectAll;
        private System.Windows.Forms.Button btnUnselectAll;
        private System.Windows.Forms.Button btnProcess;
    }
}

