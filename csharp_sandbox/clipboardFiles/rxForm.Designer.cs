namespace clipboardFiles
{
    partial class rxForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(rxForm));
            this.cancelButton = new System.Windows.Forms.Button();
            this.okButton = new System.Windows.Forms.Button();
            this.btnFirstMatch = new System.Windows.Forms.Button();
            this.textReplaceResults = new System.Windows.Forms.TextBox();
            this.textResults = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.textReplace = new System.Windows.Forms.TextBox();
            this.textSubject = new System.Windows.Forms.TextBox();
            this.textRegex = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.labelResults = new System.Windows.Forms.Label();
            this.labelSubject = new System.Windows.Forms.Label();
            this.labelRegex = new System.Windows.Forms.Label();
            this.btnRegexObjSplit = new System.Windows.Forms.Button();
            this.btnSplit = new System.Windows.Forms.Button();
            this.btnRegexObjReplace = new System.Windows.Forms.Button();
            this.btnReplace = new System.Windows.Forms.Button();
            this.labelRegexInfo = new System.Windows.Forms.LinkLabel();
            this.btnNextMatch = new System.Windows.Forms.Button();
            this.btnRegexObj = new System.Windows.Forms.Button();
            this.btnGetMatch = new System.Windows.Forms.Button();
            this.checkECMAScript = new System.Windows.Forms.CheckBox();
            this.checkIgnoreCase = new System.Windows.Forms.CheckBox();
            this.checkMultiLine = new System.Windows.Forms.CheckBox();
            this.checkDotAll = new System.Windows.Forms.CheckBox();
            this.btnMatch = new System.Windows.Forms.Button();
            this.btnTEST = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // cancelButton
            // 
            this.cancelButton.BackColor = System.Drawing.Color.Tomato;
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Font = new System.Drawing.Font("Bitstream Vera Sans Mono", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelButton.ForeColor = System.Drawing.Color.Snow;
            this.cancelButton.Location = new System.Drawing.Point(402, 73);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(75, 23);
            this.cancelButton.TabIndex = 0;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = false;
            this.cancelButton.Click += new System.EventHandler(this.cancelButton_Click);
            // 
            // okButton
            // 
            this.okButton.BackColor = System.Drawing.Color.Chartreuse;
            this.okButton.Font = new System.Drawing.Font("Bitstream Vera Sans Mono", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.okButton.Location = new System.Drawing.Point(321, 73);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(75, 23);
            this.okButton.TabIndex = 1;
            this.okButton.Text = "OK";
            this.okButton.UseVisualStyleBackColor = false;
            this.okButton.Click += new System.EventHandler(this.okButton_Click);
            // 
            // btnFirstMatch
            // 
            this.btnFirstMatch.Location = new System.Drawing.Point(129, 300);
            this.btnFirstMatch.Name = "btnFirstMatch";
            this.btnFirstMatch.Size = new System.Drawing.Size(88, 23);
            this.btnFirstMatch.TabIndex = 47;
            this.btnFirstMatch.Text = "First Match";
            this.btnFirstMatch.Click += new System.EventHandler(this.btnFirstMatch_Click);
            // 
            // textReplaceResults
            // 
            this.textReplaceResults.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textReplaceResults.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textReplaceResults.Location = new System.Drawing.Point(18, 436);
            this.textReplaceResults.Multiline = true;
            this.textReplaceResults.Name = "textReplaceResults";
            this.textReplaceResults.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textReplaceResults.Size = new System.Drawing.Size(1047, 56);
            this.textReplaceResults.TabIndex = 42;
            // 
            // textResults
            // 
            this.textResults.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textResults.BackColor = System.Drawing.SystemColors.Info;
            this.textResults.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textResults.Location = new System.Drawing.Point(16, 351);
            this.textResults.Multiline = true;
            this.textResults.Name = "textResults";
            this.textResults.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textResults.Size = new System.Drawing.Size(1047, 60);
            this.textResults.TabIndex = 40;
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(16, 420);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(111, 13);
            this.label2.TabIndex = 41;
            this.label2.Text = "Replacement Results:";
            // 
            // textReplace
            // 
            this.textReplace.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.textReplace.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textReplace.Location = new System.Drawing.Point(20, 209);
            this.textReplace.Multiline = true;
            this.textReplace.Name = "textReplace";
            this.textReplace.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textReplace.Size = new System.Drawing.Size(1043, 42);
            this.textReplace.TabIndex = 34;
            this.textReplace.Text = "replacement";
            // 
            // textSubject
            // 
            this.textSubject.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textSubject.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textSubject.Location = new System.Drawing.Point(16, 125);
            this.textSubject.Multiline = true;
            this.textSubject.Name = "textSubject";
            this.textSubject.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textSubject.Size = new System.Drawing.Size(1047, 58);
            this.textSubject.TabIndex = 32;
            this.textSubject.Text = "This is the default test subject for our regex test.";
            // 
            // textRegex
            // 
            this.textRegex.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textRegex.BackColor = System.Drawing.SystemColors.Info;
            this.textRegex.Font = new System.Drawing.Font("Courier New", 11F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textRegex.Location = new System.Drawing.Point(16, 18);
            this.textRegex.Multiline = true;
            this.textRegex.Name = "textRegex";
            this.textRegex.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textRegex.Size = new System.Drawing.Size(1047, 22);
            this.textRegex.TabIndex = 26;
            this.textRegex.Text = ".*\\.txt";
            this.textRegex.TextChanged += new System.EventHandler(this.textRegex_TextChanged);
            // 
            // label3
            // 
            this.label3.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(20, 191);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(97, 13);
            this.label3.TabIndex = 33;
            this.label3.Text = "Replacement Text:";
            // 
            // labelResults
            // 
            this.labelResults.AutoSize = true;
            this.labelResults.Location = new System.Drawing.Point(17, 335);
            this.labelResults.Name = "labelResults";
            this.labelResults.Size = new System.Drawing.Size(45, 13);
            this.labelResults.TabIndex = 39;
            this.labelResults.Text = "Results:";
            // 
            // labelSubject
            // 
            this.labelSubject.AutoSize = true;
            this.labelSubject.Location = new System.Drawing.Point(16, 109);
            this.labelSubject.Name = "labelSubject";
            this.labelSubject.Size = new System.Drawing.Size(70, 13);
            this.labelSubject.TabIndex = 31;
            this.labelSubject.Text = "Test Subject:";
            // 
            // labelRegex
            // 
            this.labelRegex.AutoSize = true;
            this.labelRegex.Location = new System.Drawing.Point(15, 2);
            this.labelRegex.Name = "labelRegex";
            this.labelRegex.Size = new System.Drawing.Size(101, 13);
            this.labelRegex.TabIndex = 25;
            this.labelRegex.Text = "Regular Expression:";
            // 
            // btnRegexObjSplit
            // 
            this.btnRegexObjSplit.Location = new System.Drawing.Point(425, 300);
            this.btnRegexObjSplit.Name = "btnRegexObjSplit";
            this.btnRegexObjSplit.Size = new System.Drawing.Size(88, 23);
            this.btnRegexObjSplit.TabIndex = 46;
            this.btnRegexObjSplit.Text = "Obj Split";
            this.btnRegexObjSplit.Click += new System.EventHandler(this.btnRegexObjSplit_Click);
            // 
            // btnSplit
            // 
            this.btnSplit.Location = new System.Drawing.Point(281, 268);
            this.btnSplit.Name = "btnSplit";
            this.btnSplit.Size = new System.Drawing.Size(72, 23);
            this.btnSplit.TabIndex = 45;
            this.btnSplit.Text = "Split";
            this.btnSplit.Click += new System.EventHandler(this.btnSplit_Click);
            // 
            // btnRegexObjReplace
            // 
            this.btnRegexObjReplace.Location = new System.Drawing.Point(321, 300);
            this.btnRegexObjReplace.Name = "btnRegexObjReplace";
            this.btnRegexObjReplace.Size = new System.Drawing.Size(96, 23);
            this.btnRegexObjReplace.TabIndex = 44;
            this.btnRegexObjReplace.Text = "Obj Replace";
            this.btnRegexObjReplace.Click += new System.EventHandler(this.btnRegexObjReplace_Click);
            // 
            // btnReplace
            // 
            this.btnReplace.Location = new System.Drawing.Point(201, 268);
            this.btnReplace.Name = "btnReplace";
            this.btnReplace.Size = new System.Drawing.Size(72, 23);
            this.btnReplace.TabIndex = 43;
            this.btnReplace.Text = "Replace";
            this.btnReplace.Click += new System.EventHandler(this.btnReplace_Click);
            // 
            // labelRegexInfo
            // 
            this.labelRegexInfo.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelRegexInfo.LinkArea = new System.Windows.Forms.LinkArea(6, 36);
            this.labelRegexInfo.Location = new System.Drawing.Point(137, 2);
            this.labelRegexInfo.Name = "labelRegexInfo";
            this.labelRegexInfo.Size = new System.Drawing.Size(432, 17);
            this.labelRegexInfo.TabIndex = 24;
            this.labelRegexInfo.TabStop = true;
            this.labelRegexInfo.Text = "Visit http://www.regular-expressions.info/ for a complete regex tutorial";
            this.labelRegexInfo.TextAlign = System.Drawing.ContentAlignment.TopRight;
            this.labelRegexInfo.UseCompatibleTextRendering = true;
            // 
            // btnNextMatch
            // 
            this.btnNextMatch.Location = new System.Drawing.Point(225, 300);
            this.btnNextMatch.Name = "btnNextMatch";
            this.btnNextMatch.Size = new System.Drawing.Size(88, 23);
            this.btnNextMatch.TabIndex = 38;
            this.btnNextMatch.Text = "Next Match";
            this.btnNextMatch.Click += new System.EventHandler(this.btnNextMatch_Click);
            // 
            // btnRegexObj
            // 
            this.btnRegexObj.Location = new System.Drawing.Point(17, 300);
            this.btnRegexObj.Name = "btnRegexObj";
            this.btnRegexObj.Size = new System.Drawing.Size(104, 23);
            this.btnRegexObj.TabIndex = 37;
            this.btnRegexObj.Text = "Create Object";
            this.btnRegexObj.Click += new System.EventHandler(this.btnRegexObj_Click);
            // 
            // btnGetMatch
            // 
            this.btnGetMatch.Location = new System.Drawing.Point(113, 268);
            this.btnGetMatch.Name = "btnGetMatch";
            this.btnGetMatch.Size = new System.Drawing.Size(80, 23);
            this.btnGetMatch.TabIndex = 36;
            this.btnGetMatch.Text = "Get Match";
            this.btnGetMatch.Click += new System.EventHandler(this.btnGetMatch_Click);
            // 
            // checkECMAScript
            // 
            this.checkECMAScript.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.checkECMAScript.Location = new System.Drawing.Point(791, 85);
            this.checkECMAScript.Name = "checkECMAScript";
            this.checkECMAScript.Size = new System.Drawing.Size(201, 21);
            this.checkECMAScript.TabIndex = 30;
            this.checkECMAScript.Text = "ECMAScript compatibility";
            // 
            // checkIgnoreCase
            // 
            this.checkIgnoreCase.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.checkIgnoreCase.Location = new System.Drawing.Point(791, 69);
            this.checkIgnoreCase.Name = "checkIgnoreCase";
            this.checkIgnoreCase.Size = new System.Drawing.Size(126, 21);
            this.checkIgnoreCase.TabIndex = 29;
            this.checkIgnoreCase.Text = "Case insensitive";
            // 
            // checkMultiLine
            // 
            this.checkMultiLine.Location = new System.Drawing.Point(17, 85);
            this.checkMultiLine.Name = "checkMultiLine";
            this.checkMultiLine.Size = new System.Drawing.Size(255, 21);
            this.checkMultiLine.TabIndex = 28;
            this.checkMultiLine.Text = "^ and $ match at embedded newlines";
            // 
            // checkDotAll
            // 
            this.checkDotAll.Location = new System.Drawing.Point(17, 69);
            this.checkDotAll.Name = "checkDotAll";
            this.checkDotAll.Size = new System.Drawing.Size(161, 21);
            this.checkDotAll.TabIndex = 27;
            this.checkDotAll.Text = "Dot matches newlines";
            this.checkDotAll.CheckedChanged += new System.EventHandler(this.checkDotAll_CheckedChanged);
            // 
            // btnMatch
            // 
            this.btnMatch.Location = new System.Drawing.Point(17, 268);
            this.btnMatch.Name = "btnMatch";
            this.btnMatch.Size = new System.Drawing.Size(88, 23);
            this.btnMatch.TabIndex = 35;
            this.btnMatch.Text = "Match Test";
            this.btnMatch.Click += new System.EventHandler(this.btnMatch_Click);
            // 
            // btnTEST
            // 
            this.btnTEST.BackColor = System.Drawing.Color.Yellow;
            this.btnTEST.Font = new System.Drawing.Font("Bitstream Vera Sans Mono", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnTEST.ForeColor = System.Drawing.Color.SaddleBrown;
            this.btnTEST.Location = new System.Drawing.Point(238, 73);
            this.btnTEST.Name = "btnTEST";
            this.btnTEST.Size = new System.Drawing.Size(75, 23);
            this.btnTEST.TabIndex = 48;
            this.btnTEST.Text = "TEST";
            this.btnTEST.UseVisualStyleBackColor = false;
            this.btnTEST.Click += new System.EventHandler(this.btnTEST_Click);
            // 
            // rxForm
            // 
            this.AcceptButton = this.okButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(1078, 543);
            this.Controls.Add(this.btnTEST);
            this.Controls.Add(this.btnFirstMatch);
            this.Controls.Add(this.textReplaceResults);
            this.Controls.Add(this.textResults);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.textReplace);
            this.Controls.Add(this.textSubject);
            this.Controls.Add(this.textRegex);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.labelResults);
            this.Controls.Add(this.labelSubject);
            this.Controls.Add(this.labelRegex);
            this.Controls.Add(this.btnRegexObjSplit);
            this.Controls.Add(this.btnSplit);
            this.Controls.Add(this.btnRegexObjReplace);
            this.Controls.Add(this.btnReplace);
            this.Controls.Add(this.labelRegexInfo);
            this.Controls.Add(this.btnNextMatch);
            this.Controls.Add(this.btnRegexObj);
            this.Controls.Add(this.btnGetMatch);
            this.Controls.Add(this.checkECMAScript);
            this.Controls.Add(this.checkIgnoreCase);
            this.Controls.Add(this.checkMultiLine);
            this.Controls.Add(this.checkDotAll);
            this.Controls.Add(this.btnMatch);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.cancelButton);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MinimumSize = new System.Drawing.Size(500, 450);
            this.Name = "rxForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "clipboardFiles_rxForm";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.Button btnFirstMatch;
        private System.Windows.Forms.TextBox textReplaceResults;
        private System.Windows.Forms.TextBox textResults;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox textReplace;
        private System.Windows.Forms.TextBox textSubject;
        private System.Windows.Forms.TextBox textRegex;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label labelResults;
        private System.Windows.Forms.Label labelSubject;
        private System.Windows.Forms.Label labelRegex;
        private System.Windows.Forms.Button btnRegexObjSplit;
        private System.Windows.Forms.Button btnSplit;
        private System.Windows.Forms.Button btnRegexObjReplace;
        private System.Windows.Forms.Button btnReplace;
        private System.Windows.Forms.LinkLabel labelRegexInfo;
        private System.Windows.Forms.Button btnNextMatch;
        private System.Windows.Forms.Button btnRegexObj;
        private System.Windows.Forms.Button btnGetMatch;
        private System.Windows.Forms.CheckBox checkECMAScript;
        private System.Windows.Forms.CheckBox checkIgnoreCase;
        private System.Windows.Forms.CheckBox checkMultiLine;
        private System.Windows.Forms.CheckBox checkDotAll;
        private System.Windows.Forms.Button btnMatch;
        private System.Windows.Forms.Button btnTEST;
    }
}