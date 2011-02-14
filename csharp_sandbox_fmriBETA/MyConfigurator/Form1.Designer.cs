namespace MyConfigurator
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
            this.buttonOne = new System.Windows.Forms.Button();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.buttonShowConfigPath = new System.Windows.Forms.Button();
            this.buttonExit = new System.Windows.Forms.Button();
            this.txtPathConfig = new System.Windows.Forms.TextBox();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabelConfigPath = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelConfigFile = new System.Windows.Forms.ToolStripStatusLabel();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // buttonOne
            // 
            this.buttonOne.Location = new System.Drawing.Point(51, 34);
            this.buttonOne.Name = "buttonOne";
            this.buttonOne.Size = new System.Drawing.Size(111, 23);
            this.buttonOne.TabIndex = 0;
            this.buttonOne.Text = "One";
            this.buttonOne.UseVisualStyleBackColor = true;
            this.buttonOne.Click += new System.EventHandler(this.buttonOne_Click);
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(168, 34);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(482, 222);
            this.dataGridView1.TabIndex = 1;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // buttonShowConfigPath
            // 
            this.buttonShowConfigPath.Location = new System.Drawing.Point(51, 63);
            this.buttonShowConfigPath.Name = "buttonShowConfigPath";
            this.buttonShowConfigPath.Size = new System.Drawing.Size(111, 23);
            this.buttonShowConfigPath.TabIndex = 2;
            this.buttonShowConfigPath.Text = "ShowConfigPath";
            this.buttonShowConfigPath.UseVisualStyleBackColor = true;
            this.buttonShowConfigPath.Click += new System.EventHandler(this.buttonShowConfigPath_Click);
            // 
            // buttonExit
            // 
            this.buttonExit.Location = new System.Drawing.Point(51, 92);
            this.buttonExit.Name = "buttonExit";
            this.buttonExit.Size = new System.Drawing.Size(75, 23);
            this.buttonExit.TabIndex = 3;
            this.buttonExit.Text = "Exit";
            this.buttonExit.UseVisualStyleBackColor = true;
            this.buttonExit.Click += new System.EventHandler(this.buttonExit_Click);
            // 
            // txtPathConfig
            // 
            this.txtPathConfig.Location = new System.Drawing.Point(51, 8);
            this.txtPathConfig.Name = "txtPathConfig";
            this.txtPathConfig.Size = new System.Drawing.Size(599, 20);
            this.txtPathConfig.TabIndex = 4;
            this.txtPathConfig.Text = "path to config file";
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabelConfigPath,
            this.toolStripStatusLabelConfigFile});
            this.statusStrip1.Location = new System.Drawing.Point(0, 277);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.RenderMode = System.Windows.Forms.ToolStripRenderMode.Professional;
            this.statusStrip1.Size = new System.Drawing.Size(677, 22);
            this.statusStrip1.TabIndex = 5;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabelConfigPath
            // 
            this.toolStripStatusLabelConfigPath.Name = "toolStripStatusLabelConfigPath";
            this.toolStripStatusLabelConfigPath.Size = new System.Drawing.Size(60, 17);
            this.toolStripStatusLabelConfigPath.Text = "ConfigPath";
            // 
            // toolStripStatusLabelConfigFile
            // 
            this.toolStripStatusLabelConfigFile.Name = "toolStripStatusLabelConfigFile";
            this.toolStripStatusLabelConfigFile.Size = new System.Drawing.Size(54, 17);
            this.toolStripStatusLabelConfigFile.Text = "ConfigFile";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(677, 299);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.txtPathConfig);
            this.Controls.Add(this.buttonExit);
            this.Controls.Add(this.buttonShowConfigPath);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.buttonOne);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonOne;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button buttonShowConfigPath;
        private System.Windows.Forms.Button buttonExit;
        private System.Windows.Forms.TextBox txtPathConfig;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelConfigPath;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelConfigFile;
    }
}

