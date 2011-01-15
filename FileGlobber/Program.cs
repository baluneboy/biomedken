using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

// This line allows us to use classes like Regex and Match
// without having to spell out the entire location.
using System.Text.RegularExpressions;

using ClassLibraryFileGlobber;

namespace RegexDemo
{
    /// <summary>
    /// Application to demonstrate the use of regular expressions in the .NET framework
    /// Copyright (c) 2003 Jan Goyvaerts.  All rights reserved.
    /// Visit http://www.regular-expressions.info for a detailed tutorial to regular expressions.
    ///
    /// This source code is provided for educational purposes only, without 
    /// any warranty of any kind.  Distribution of this source code and/or the
    /// application compiled from this source code is prohibited.  Please refer 
    /// everybody interested in getting a copy of the source code to 
    /// http://www.regular-expressions.info where it can be downloaded.
    /// </summary>
    public class FormRegex : System.Windows.Forms.Form
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;
        // Design time objects
        private System.Windows.Forms.LinkLabel labelRegexInfo;
        private System.Windows.Forms.TextBox textRegex;
        private System.Windows.Forms.Label labelRegex;
        private System.Windows.Forms.Label labelSubject;
        private System.Windows.Forms.Button btnMatch;
        private System.Windows.Forms.TextBox textSubject;
        private System.Windows.Forms.TextBox textResults;
        private System.Windows.Forms.Label labelResults;
        private System.Windows.Forms.CheckBox checkDotAll;
        private System.Windows.Forms.CheckBox checkMultiLine;
        private System.Windows.Forms.CheckBox checkIgnoreCase;
        private System.Windows.Forms.CheckBox checkECMAScript;
        private System.Windows.Forms.Button btnGetMatch;
        private System.Windows.Forms.Button btnRegexObj;
        private System.Windows.Forms.Button btnNextMatch;
        private System.Windows.Forms.TextBox textReplace;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox textReplaceResults;
        private System.Windows.Forms.Button btnReplace;
        private System.Windows.Forms.Button btnRegexObjReplace;
        private System.Windows.Forms.Button btnSplit;
        private System.Windows.Forms.Button btnRegexObjSplit;
        private System.Windows.Forms.Button btnFirstMatch;

        public FormRegex()
        {
            //
            // Required for Windows Form Designer support
            //
            InitializeComponent();

            //
            // TODO: Add any constructor code after InitializeComponent call
            //
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
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
            this.textRegex = new System.Windows.Forms.TextBox();
            this.labelRegex = new System.Windows.Forms.Label();
            this.labelSubject = new System.Windows.Forms.Label();
            this.btnMatch = new System.Windows.Forms.Button();
            this.textSubject = new System.Windows.Forms.TextBox();
            this.textResults = new System.Windows.Forms.TextBox();
            this.labelResults = new System.Windows.Forms.Label();
            this.checkDotAll = new System.Windows.Forms.CheckBox();
            this.checkMultiLine = new System.Windows.Forms.CheckBox();
            this.checkIgnoreCase = new System.Windows.Forms.CheckBox();
            this.checkECMAScript = new System.Windows.Forms.CheckBox();
            this.btnGetMatch = new System.Windows.Forms.Button();
            this.btnRegexObj = new System.Windows.Forms.Button();
            this.btnNextMatch = new System.Windows.Forms.Button();
            this.labelRegexInfo = new System.Windows.Forms.LinkLabel();
            this.textReplace = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.textReplaceResults = new System.Windows.Forms.TextBox();
            this.btnReplace = new System.Windows.Forms.Button();
            this.btnRegexObjReplace = new System.Windows.Forms.Button();
            this.btnSplit = new System.Windows.Forms.Button();
            this.btnRegexObjSplit = new System.Windows.Forms.Button();
            this.btnFirstMatch = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // textRegex
            // 
            this.textRegex.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textRegex.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textRegex.Location = new System.Drawing.Point(7, 21);
            this.textRegex.Multiline = true;
            this.textRegex.Name = "textRegex";
            this.textRegex.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textRegex.Size = new System.Drawing.Size(1167, 49);
            this.textRegex.TabIndex = 2;
            this.textRegex.Text = "^(?<DIR>c:\\\\temp\\\\dup[^\\\\]*)\\\\(?<FILE>file[^\\\\]*\\.txt)";

            // 
            // labelRegex
            // 
            this.labelRegex.AutoSize = true;
            this.labelRegex.Location = new System.Drawing.Point(6, 5);
            this.labelRegex.Name = "labelRegex";
            this.labelRegex.Size = new System.Drawing.Size(135, 17);
            this.labelRegex.TabIndex = 1;
            this.labelRegex.Text = "Regular Expression:";
            // 
            // labelSubject
            // 
            this.labelSubject.AutoSize = true;
            this.labelSubject.Location = new System.Drawing.Point(7, 112);
            this.labelSubject.Name = "labelSubject";
            this.labelSubject.Size = new System.Drawing.Size(91, 17);
            this.labelSubject.TabIndex = 7;
            this.labelSubject.Text = "Test Subject:";
            // 
            // btnMatch
            // 
            this.btnMatch.Location = new System.Drawing.Point(8, 272);
            this.btnMatch.Name = "btnMatch";
            this.btnMatch.Size = new System.Drawing.Size(88, 23);
            this.btnMatch.TabIndex = 11;
            this.btnMatch.Text = "Match Test";
            this.btnMatch.Click += new System.EventHandler(this.btnMatch_Click);
            // 
            // textSubject
            // 
            this.textSubject.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textSubject.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textSubject.Location = new System.Drawing.Point(7, 128);
            this.textSubject.Multiline = true;
            this.textSubject.Name = "textSubject";
            this.textSubject.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textSubject.Size = new System.Drawing.Size(887, 136);
            this.textSubject.TabIndex = 8;
            this.textSubject.Text = "c:\\temp\\dupstination\\fileABC.txt";

            // 
            // textResults
            // 
            this.textResults.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textResults.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textResults.Location = new System.Drawing.Point(7, 352);
            this.textResults.Multiline = true;
            this.textResults.Name = "textResults";
            this.textResults.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textResults.Size = new System.Drawing.Size(887, 189);
            this.textResults.TabIndex = 16;
            // 
            // labelResults
            // 
            this.labelResults.AutoSize = true;
            this.labelResults.Location = new System.Drawing.Point(8, 336);
            this.labelResults.Name = "labelResults";
            this.labelResults.Size = new System.Drawing.Size(59, 17);
            this.labelResults.TabIndex = 15;
            this.labelResults.Text = "Results:";
            // 
            // checkDotAll
            // 
            this.checkDotAll.Location = new System.Drawing.Point(8, 72);
            this.checkDotAll.Name = "checkDotAll";
            this.checkDotAll.Size = new System.Drawing.Size(161, 21);
            this.checkDotAll.TabIndex = 3;
            this.checkDotAll.Text = "Dot matches newlines";
            this.checkDotAll.Click += new System.EventHandler(this.checkDotAll_Click);
            // 
            // checkMultiLine
            // 
            this.checkMultiLine.Location = new System.Drawing.Point(8, 88);
            this.checkMultiLine.Name = "checkMultiLine";
            this.checkMultiLine.Size = new System.Drawing.Size(255, 21);
            this.checkMultiLine.TabIndex = 4;
            this.checkMultiLine.Text = "^ and $ match at embedded newlines";
            // 
            // checkIgnoreCase
            // 
            this.checkIgnoreCase.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.checkIgnoreCase.Location = new System.Drawing.Point(902, 72);
            this.checkIgnoreCase.Name = "checkIgnoreCase";
            this.checkIgnoreCase.Size = new System.Drawing.Size(126, 21);
            this.checkIgnoreCase.TabIndex = 5;
            this.checkIgnoreCase.Text = "Case insensitive";
            // 
            // checkECMAScript
            // 
            this.checkECMAScript.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.checkECMAScript.Location = new System.Drawing.Point(902, 88);
            this.checkECMAScript.Name = "checkECMAScript";
            this.checkECMAScript.Size = new System.Drawing.Size(201, 21);
            this.checkECMAScript.TabIndex = 6;
            this.checkECMAScript.Text = "ECMAScript compatibility";
            this.checkECMAScript.Click += new System.EventHandler(this.checkECMAScript_Click);
            // 
            // btnGetMatch
            // 
            this.btnGetMatch.Location = new System.Drawing.Point(104, 272);
            this.btnGetMatch.Name = "btnGetMatch";
            this.btnGetMatch.Size = new System.Drawing.Size(80, 23);
            this.btnGetMatch.TabIndex = 12;
            this.btnGetMatch.Text = "Get Match";
            this.btnGetMatch.Click += new System.EventHandler(this.btnGetMatch_Click);
            // 
            // btnRegexObj
            // 
            this.btnRegexObj.Location = new System.Drawing.Point(8, 304);
            this.btnRegexObj.Name = "btnRegexObj";
            this.btnRegexObj.Size = new System.Drawing.Size(104, 23);
            this.btnRegexObj.TabIndex = 13;
            this.btnRegexObj.Text = "Create Object";
            this.btnRegexObj.Click += new System.EventHandler(this.btnRegexObj_Click);
            // 
            // btnNextMatch
            // 
            this.btnNextMatch.Location = new System.Drawing.Point(216, 304);
            this.btnNextMatch.Name = "btnNextMatch";
            this.btnNextMatch.Size = new System.Drawing.Size(88, 23);
            this.btnNextMatch.TabIndex = 14;
            this.btnNextMatch.Text = "Next Match";
            this.btnNextMatch.Click += new System.EventHandler(this.btnNextMatch_Click);
            // 
            // labelRegexInfo
            // 
            this.labelRegexInfo.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelRegexInfo.LinkArea = new System.Windows.Forms.LinkArea(6, 36);
            this.labelRegexInfo.Location = new System.Drawing.Point(128, 5);
            this.labelRegexInfo.Name = "labelRegexInfo";
            this.labelRegexInfo.Size = new System.Drawing.Size(432, 17);
            this.labelRegexInfo.TabIndex = 0;
            this.labelRegexInfo.TabStop = true;
            this.labelRegexInfo.Text = "Visit http://www.regular-expressions.info/ for a complete regex tutorial";
            this.labelRegexInfo.TextAlign = System.Drawing.ContentAlignment.TopRight;
            this.labelRegexInfo.UseCompatibleTextRendering = true;
            // 
            // textReplace
            // 
            this.textReplace.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.textReplace.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textReplace.Location = new System.Drawing.Point(902, 128);
            this.textReplace.Multiline = true;
            this.textReplace.Name = "textReplace";
            this.textReplace.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textReplace.Size = new System.Drawing.Size(272, 136);
            this.textReplace.TabIndex = 10;
            this.textReplace.Text = "${FILE} in ${DIR}";
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(902, 112);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(126, 17);
            this.label1.TabIndex = 9;
            this.label1.Text = "Replacement Text:";
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(902, 336);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(146, 17);
            this.label2.TabIndex = 17;
            this.label2.Text = "Replacement Results:";
            // 
            // textReplaceResults
            // 
            this.textReplaceResults.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.textReplaceResults.Font = new System.Drawing.Font("Courier New", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textReplaceResults.Location = new System.Drawing.Point(902, 352);
            this.textReplaceResults.Multiline = true;
            this.textReplaceResults.Name = "textReplaceResults";
            this.textReplaceResults.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textReplaceResults.Size = new System.Drawing.Size(273, 189);
            this.textReplaceResults.TabIndex = 18;
            // 
            // btnReplace
            // 
            this.btnReplace.Location = new System.Drawing.Point(192, 272);
            this.btnReplace.Name = "btnReplace";
            this.btnReplace.Size = new System.Drawing.Size(72, 23);
            this.btnReplace.TabIndex = 19;
            this.btnReplace.Text = "Replace";
            this.btnReplace.Click += new System.EventHandler(this.btnReplace_Click);
            // 
            // btnRegexObjReplace
            // 
            this.btnRegexObjReplace.Location = new System.Drawing.Point(312, 304);
            this.btnRegexObjReplace.Name = "btnRegexObjReplace";
            this.btnRegexObjReplace.Size = new System.Drawing.Size(96, 23);
            this.btnRegexObjReplace.TabIndex = 20;
            this.btnRegexObjReplace.Text = "Obj Replace";
            this.btnRegexObjReplace.Click += new System.EventHandler(this.btnRegexObjReplace_Click);
            // 
            // btnSplit
            // 
            this.btnSplit.Location = new System.Drawing.Point(272, 272);
            this.btnSplit.Name = "btnSplit";
            this.btnSplit.Size = new System.Drawing.Size(72, 23);
            this.btnSplit.TabIndex = 21;
            this.btnSplit.Text = "Split";
            this.btnSplit.Click += new System.EventHandler(this.btnSplit_Click);
            // 
            // btnRegexObjSplit
            // 
            this.btnRegexObjSplit.Location = new System.Drawing.Point(416, 304);
            this.btnRegexObjSplit.Name = "btnRegexObjSplit";
            this.btnRegexObjSplit.Size = new System.Drawing.Size(88, 23);
            this.btnRegexObjSplit.TabIndex = 22;
            this.btnRegexObjSplit.Text = "Obj Split";
            this.btnRegexObjSplit.Click += new System.EventHandler(this.btnRegexObjSplit_Click);
            // 
            // btnFirstMatch
            // 
            this.btnFirstMatch.Location = new System.Drawing.Point(120, 304);
            this.btnFirstMatch.Name = "btnFirstMatch";
            this.btnFirstMatch.Size = new System.Drawing.Size(88, 23);
            this.btnFirstMatch.TabIndex = 23;
            this.btnFirstMatch.Text = "First Match";
            this.btnFirstMatch.Click += new System.EventHandler(this.btnFirstMatch_Click);
            // 
            // FormRegex
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(6, 16);
            this.ClientSize = new System.Drawing.Size(1180, 552);
            this.Controls.Add(this.btnFirstMatch);
            this.Controls.Add(this.textReplaceResults);
            this.Controls.Add(this.textResults);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.textReplace);
            this.Controls.Add(this.textSubject);
            this.Controls.Add(this.textRegex);
            this.Controls.Add(this.label1);
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
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.MinimumSize = new System.Drawing.Size(500, 450);
            this.Name = "FormRegex";
            this.Text = "Regular Expressions Demo";
            this.Load += new System.EventHandler(this.FormRegex_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.Run(new FormRegex());
        }

        private void checkDotAll_Click(object sender, System.EventArgs e)
        {
            // "Dot all" and "ECMAScript" are mutually exclusive options.
            if (checkDotAll.Checked) checkECMAScript.Checked = false;
        }

        private void checkECMAScript_Click(object sender, System.EventArgs e)
        {
            // "Dot all" and "ECMAScript" are mutually exclusive options.
            if (checkECMAScript.Checked) checkDotAll.Checked = false;
        }

        private RegexOptions getRegexOptions()
        {
            // "Dot all" and "ECMAScript" are mutually exclusive options.
            // If we include them both, then the Regex() constructor or the 
            // Regex.Match() method will raise an exception
            System.Diagnostics.Trace.Assert(!(checkDotAll.Checked && checkECMAScript.Checked),
                   "DotAll and ECMAScript options are mutually exclusive");
            // Construct a RegexOptions object
            // If the options are predetermined, you don't need to use a RegexOptions object
            // You can simply pass something like RegexOptions.Multiline | RegexOptions.Ignorecase
            // directly to the Regex() constructor or the Regex.Match() method
            RegexOptions options = new RegexOptions();
            // If true, the dot matches any character, including a newline
            // If false, the dot matches any character, except a newline
            if (checkDotAll.Checked) options |= RegexOptions.Singleline;
            // If true, the caret ^ matches after a newline, and the dollar $ matches 
            // before a newline, as well as at the start and end of the subject string
            // If false, the caret only matches at the start of the string
            // and the dollar only at the end of the string
            if (checkMultiLine.Checked) options |= RegexOptions.Multiline;
            // If true, literal characters and character classes are matched case insensitively
            if (checkIgnoreCase.Checked) options |= RegexOptions.IgnoreCase;
            // If true, \w, \d and \s match ASCII characters only,
            // and \10 is backreference 1 followed by a literal 0 rather than octal escape 10.
            if (checkECMAScript.Checked) options |= RegexOptions.ECMAScript;
            return options;
        }

        private void btnMatch_Click(object sender, System.EventArgs e)
        {
            // This method illustrates the easiest way to test if a string can be matched
            // by a regex using the System.Text.RegularExpressions.Regex.Match static method.
            // This way is recommended when you only want to validate a single string every now and then.

            // Note that IsMatch() will also return True if the regex matches part of the string only.
            // If you only want it to return True if the regex matches the entire string,
            // simply prepend a caret and append a dollar sign to the regex to anchor it at the start and end.

            // Note that when typing in a regular expression into textSubject,
            // backslashes are interpreted at the regex level.
            // So typing in \( will match a literal ( character and \\ matches a literal backslash.
            // When passing literal strings in your source code, you need to escape backslashes in strings as usual.
            // So the string "\\(" matches a literal ( and "\\\\" matches a single literal backslash.
            // To reduce confusion, I suggest you use verbatim strings instead:
            // @"\(" matches a literal ( and @"\\" matches a literal backslash.
            // You can omit the last parameter with the regex options if you don't want to specify any.
            textReplaceResults.Text = "N/A";
            try
            {
                if (Regex.IsMatch(textSubject.Text, textRegex.Text, getRegexOptions()))
                {
                    textResults.Text = "The regex matches part or all of the subject";
                }
                else
                {
                    textResults.Text = "The regex cannot be matched in the subject";
                }
            }
            catch (Exception ex)
            {
                // Most likely cause is a syntax error in the regular expression
                textResults.Text = "Regex.IsMatch() threw an exception:\r\n" + ex.Message;
            }
        }

        private void btnGetMatch_Click(object sender, System.EventArgs e)
        {
            // Illustrates the easiest way to get the text of the first match
            // using the System.Text.RegularExpressions.Regex.Match static method.
            // Useful for easily extracting a string form another string.
            // You can omit the last parameter with the regex options if you don't want to specify any.
            // If there's no match, Regex.Match.Value returns an empty string.
            // If you are only interested in part of the regex match, you can use 
            // .Groups[3].Value instead of .Value to get the text matched between 
            // the third pair of round brackets in the regular expression
            textReplaceResults.Text = "N/A";
            try
            {
                textResults.Text = Regex.Match(textSubject.Text, textRegex.Text, getRegexOptions()).Value;
            }
            catch (Exception ex)
            {
                // Most likely cause is a syntax error in the regular expression
                textResults.Text = "Regex.Match() threw an exception:\r\n" + ex.Message;
            }
        }

        private void btnReplace_Click(object sender, System.EventArgs e)
        {
            // Illustrates the easiest way to do a regex-based search-and-replace on a single string
            // using the System.Text.RegularExpressions.Regex.Replace static method.
            // This method will replace ALL matches of the regex in the subject with the replacement text.
            // If there are no matches, Replace() will return the subject string unchanged.
            // If you only want to replace certain matches, you have to use the method 
            // illustrated in btnRegexObjReplace_click.
            // You can omit the last parameter with the regex options if you don't want to specify any.
            // In the replacement text (textReplace.Text), you can use $& to insert 
            // the entire regex match, and $1, $2, $3, etc. for the backreferences 
            // (text matched by the part in the regex between the first, second, third, etc.
            // pair of round brackets)
            // $$ inserts a single $ character
            // $` (dollar backtick) inserts the text in the subject to the left of the regex match
            // $' (dollar single quote) inserts the text in the subject 
            //    to the right of the end of the regex match
            // $_ inserts the entire subject text
            try
            {
                textReplaceResults.Text = Regex.Replace(textSubject.Text, textRegex.Text,
                                                        textReplace.Text, getRegexOptions());
                textResults.Text = "N/A";
            }
            catch (Exception ex)
            {
                // Most likely cause is a syntax error in the regular expression
                textResults.Text = "Regex.Replace() threw an exception:\r\n" + ex.Message;
                textReplaceResults.Text = "N/A";
            }
        }

        private void printSplitArray(string[] array)
        {
            textResults.Text = "";
            for (int i = 0; i < array.Length; i++)
            {
                textResults.AppendText(i.ToString() + ": \"" + array[i] + "\"\r\n");
            }
        }

        private void btnSplit_Click(object sender, System.EventArgs e)
        {
            // Regex.Split allows you to split a single string into an array of strings
            // using a regular expression.  This example illustrates the easiest way 
            // to do this; use btnRegexObjSplit_Click if you need to split many strings.
            // The string is cut at each point where the regex matches.  The part of 
            // the string matched by the regex is thrown away.  If the regex contains
            // capturing parentheses, then the part of the string matched by each of 
            // them is also inserted into the array.
            // To summarize, the array will contain 
            // (indenting for clarity; the array is one-dimensional):
            // - the part of the string before the first regex match
            //   - the part of the string captured in the first pair of parentheses 
            //     in the first regex match
            //   - the part of the string captured in the second pair of parentheses 
            //     in the first regex match
            //   - etc. until the last pair of parentheses in the first match
            // - the part of the string after the first match, and before the second match
            //   - capturing parentheses for the second match
            // - etc. for all regex matches
            // - part of the string after the last regex match
            // Tips: If you want the delimiters to be separate items in the array, 
            //       put round brackets around the entire regex.
            //       If you need parentheses for grouping, but don't want their results
            //       in the array, use (?:subregex) non-capturing parentheses.
            //       If you want the delimiters to be included with the split items 
            //       in the array, use lookahead or lookbehind to match a position 
            //       in the string rather than characters.
            // E.g.: The regex "," separates a comma-delimited list, deleting the commas
            //       The regex "(,)" separates a comma-delimited list, inserting the 
            //       commas as separate strings into the array of strings.
            //       The regex "(?<=,)" separates a comma-delimited list, leaving the 
            //       commas at the end of each string in the array.
            // You can omit the last parameter with the regex options 
            // if you don't want to specify any.
            textReplaceResults.Text = "N/A";
            try
            {
                printSplitArray(Regex.Split(textSubject.Text, textRegex.Text, getRegexOptions()));
            }
            catch (Exception ex)
            {
                // Most likely cause is a syntax error in the regular expression
                textResults.Text = "Regex.Split() threw an exception:\r\n" + ex.Message;
            }
        }

        private Regex regexObj;
        private Match matchObj;

        private void printMatch()
        {
            // Regex.Match constructs and returns a Match object
            // You can query this object to get all possible information about the regex match
            if (matchObj.Success)
            {
                textResults.Text = "Match offset: " + matchObj.Index.ToString() + "\r\n";
                textResults.Text += "Match length: " + matchObj.Length.ToString() + "\r\n";
                textResults.Text += "Matched text: " + matchObj.Value + "\r\n";
                if (matchObj.Groups.Count > 1)
                {
                    // matchObj.Groups[0] holds the entire regex match also held by matchObj itself
                    // The other Group objects hold the matches for capturing parentheses in the regex
                    for (int i = 1; i < matchObj.Groups.Count; i++)
                    {
                        Group g = matchObj.Groups[i];
                        if (g.Success)
                        {
                            textResults.Text += "Group " + i.ToString() +
                                                " offset: " + g.Index.ToString() + "\r\n";
                            textResults.Text += "Group " + i.ToString() +
                                                " length: " + g.Length.ToString() + "\r\n";
                            textResults.Text += "Group " + i.ToString() +
                                                " text: " + g.Value + "\r\n";
                        }
                        else
                        {
                            textResults.Text += "Group " + i.ToString() +
                                                " did not participate in the overall match\r\n";
                        }
                    }
                }
                else
                {
                    textResults.Text += "no backreferences/groups";
                }
            }
            else
            {
                textResults.Text = "no match";
            }
            textReplaceResults.Text = "N/A";
        }

        private void btnRegexObj_Click(object sender, System.EventArgs e)
        {
            // Clean up, in case we cannot construct the new regex object
            regexObj = null;
            textReplaceResults.Text = "N/A";
            // If you want to do many searches using the same regular expression,
            // you should first construct a System.Text.RegularExpressions.Regex object
            // and then call its Match method (one of the overloaded forms that does
            // not take the regular expression as a parameter)
            // regexOptions may be omitted if all options are off
            try
            {
                regexObj = new Regex(textRegex.Text, getRegexOptions());
                textResults.Text = "Regex object constructed.  Click on one of the " +
                  "buttons to the right of the Create Object button to use the regex object.";
            }
            catch (Exception ex)
            {
                // Most likely cause is a syntax error in the regular expression
                textResults.Text = "Regex constructor threw an exception:\r\n" + ex.Message;
                return;
            }
        }

        private void btnFirstMatch_Click(object sender, System.EventArgs e)
        {
            // Find the first match using regexObj constructed in btnRegexObj_Click()
            // and store all the details in matchObj
            // matchObj is used in btnNextMatch_click() to find subsequent matches
            if (regexObj == null)
            {
                textResults.Text = "First click on Create Object to create the regular expression " +
                  "object.  Then click on First Match to find the first match in the subject string.";
                textReplaceResults.Text = "N/A";
            }
            else
            {
                matchObj = regexObj.Match(textSubject.Text);
                printMatch();
            }
        }

        private void btnNextMatch_Click(object sender, System.EventArgs e)
        {
            // Tell the regex engine to find another match after the previous match
            // Note that even if you change textRegex.Text or textSubject.Text between
            // clicking btnRegexObj, btnFirstMatch and btnNextMatch, the regex engine
            // will continue to search the same subject string passed in the 
            // regexObj.Match call in btnFirstMatch_Click using the same regular 
            // expression passed to the Regex() constructor in btnRegexObj_Click
            if (matchObj == null)
            {
                textResults.Text = "Please use the First Match button to find the first match.\r\n" +
                                   "Then use this button to find following matches.";
                textReplaceResults.Text = "N/A";
            }
            else
            {
                matchObj = matchObj.NextMatch();
                printMatch();
            }
        }

        private void btnRegexObjReplace_Click(object sender, System.EventArgs e)
        {
            // If you want to do many search-and-replace operations using the same
            // regular expression, you should first construct a 
            // System.Text.RegularExpressions.Regex object and then call its Replace()
            // method (one of the overloaded forms that does not take the regular 
            // expression as a parameter).
            // This way also allows to to specify two additional parameters allowing 
            // you to control how many replacements will be made.
            // The easy way illustrated in btnReplace_click will always replace ALL matches.
            // See the comments with btnReplace_click for explanation of the special 
            // $-placeholders you can use in the replacement text.
            // You can mix calls to regexObj.Match() and regexObj.Replace() as you see fit.
            // The results of the calls will not affect the other calls.
            if (regexObj == null)
            {
                textReplaceResults.Text = "Please use the Create Objects button to construct the regex object.\r\n" +
                  "Then use this button to do a search-and-replace using the subject and replacement texts.";
            }
            else
            {
                // As used in this example, Replace() will replace ALL matches of the 
                // regex in the subject with the replacement text.
                // If you want to limit the number of matches replaced, specify a third
                // parameter with the number of matches to be replaced.
                // If you specify 3, the first (left-to-right) three matches will be replaced.
                // You can also specify a fourth parameter with the character position
                // in the subject where the regex search should begin.
                // If the third parameter is negative, all matches after the starting
                // position will be replaced like when the third and fourth parametersare omitted.
                textReplaceResults.Text = regexObj.Replace(textSubject.Text, textReplace.Text /*, 
                                                   ReplaceCount, ReplaceStart*/
                                                                                        );
            }
            textResults.Text = "N/A";
        }

        private void btnRegexObjSplit_Click(object sender, System.EventArgs e)
        {
            // If you want to split many strings using the same regular expression,
            // you should first construct a System.Text.RegularExpressions.Regex object
            // and then call its Split method (one of the overloaded forms that does 
            // not take the regular expression as a parameter).
            // See btnSplit_Click for an explanation how Split() works.
            // If you first construct a Regex object, you can specify two additional
            // parameters to Split() after the subject string.
            // The optional second parameter indicates how many times Split() is 
            // allowed to split the string.  A negative number causes the string to be
            // split at all regex matches.  If the number is smaller than the number 
            // of possible matches, then the last string in the returned array
            // will contain the unsplit remainder of the string.
            // The optional third parameter indicates the character position in the 
            // string where Split() can start to look for regex matches.
            // If you specify the third parameter, then the first string in the returned 
            // array will contain the unsplit start of the string as well as
            // the part of the string between the starting position and the first regex match.
            // You can mix calls to regexObj.Match() and regexObj.Split() as you see fit.
            // The results of the calls will not affect the other calls.
            textReplaceResults.Text = "N/A";
            if (regexObj == null)
            {
                textResults.Text = "Please use the Create Objects button to construct the regex object.\r\n" +
                                   "Then use this button to split the subject into an array of strings.";
            }
            else
            {
                printSplitArray(regexObj.Split(textSubject.Text) /*, SplitCount, SplitStart*/ );
            }
        }

        private void FormRegex_Load(object sender, EventArgs e)
        {

        }

    }
}
