using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Net.Mail;
using System.Net.Sockets;
using System.Runtime.InteropServices;

// This line allows us to use classes like Regex and Match
// without having to spell out the entire location.
using System.Text.RegularExpressions;

namespace clipboardFiles
{
    public partial class rxForm : Form
    {
        public rxForm()
        {
            InitializeComponent();
            string[] cmd;
            cmd = Environment.GetCommandLineArgs();
            string pth = @"" + cmd[1];
            for (int i = 2; i < cmd.Length; i++) // skip index = [0] because this is path\name of exe
            {
                pth = pth + " " + cmd[i];
            }
            textSubject.Text = pth;
        }

        public void setResults(string fileList)
        {
            textResults.Text = fileList;
            clipboardFiles.fileList = "";
        }

        public void showMe(string s)
        {
            System.Windows.Forms.MessageBox.Show(s, "Showing You This", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            clipboardFiles.rx = textRegex.Text;
            IniFileIO.WriteIniValue("RegularExpressionSection", "Regex", clipboardFiles.rx, "c:\\temp\\clipboardfiles.ini");
            this.Close();
        }

        private void cancelButton_Click(object sender, EventArgs e)
        {
            clipboardFiles.rx = "CANCEL";
            this.Close();
        }

        private void checkDotAll_CheckedChanged(object sender, EventArgs e)
        {
            // "Dot all" and "ECMAScript" are mutually exclusive options.
            if (checkDotAll.Checked) checkECMAScript.Checked = false;
        }

        private void checkECMAScript_CheckedChanged(object sender, EventArgs e)
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

        private void printSplitArray(string[] array)
        {
            textResults.Text = "";
            for (int i = 0; i < array.Length; i++)
            {
                textResults.AppendText(i.ToString() + ": \"" + array[i] + "\"\r\n");
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

        private void btnTEST_Click(object sender, EventArgs e)
        {
            DirectoryInfo root = new DirectoryInfo(@textSubject.Text);
            clipboardFiles.snagFiles(root,textRegex.Text);
            if (clipboardFiles.fileList.Equals(""))
            {
                setResults("no match");
                labelResults.Text = "Results: (0 objects found)";
            }
            else
            {
                int len = TextTool.CountStringOccurrences(clipboardFiles.fileList, "\r\n"); // count CRLFs
                setResults(clipboardFiles.fileList);
                labelResults.Text = "Results: (" + String.Format("{0}", len) + " objects found)";
            }
        }

        private void btnMatch_Click(object sender, EventArgs e)
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
            textReplaceResults.Text = "N/A not applicable";
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

        private void btnGetMatch_Click(object sender, EventArgs e)
        {
            // Illustrates the easiest way to get the text of the first match
            // using the System.Text.RegularExpressions.Regex.Match static method.
            // Useful for easily extracting a string form another string.
            // You can omit the last parameter with the regex options if you don't want to specify any.
            // If there's no match, Regex.Match.Value returns an empty string.
            // If you are only interested in part of the regex match, you can use 
            // .Groups[3].Value instead of .Value to get the text matched between 
            // the third pair of round brackets in the regular expression
            textReplaceResults.Text = "N/A not applicable";
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

        private void btnReplace_Click(object sender, EventArgs e)
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

        private void btnSplit_Click(object sender, EventArgs e)
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

        private void btnRegexObj_Click(object sender, EventArgs e)
        {
            // Clean up, in case we cannot construct the new regex object
            regexObj = null;
            textReplaceResults.Text = "N/A not applicable";
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

        private void btnFirstMatch_Click(object sender, EventArgs e)
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

        private void btnNextMatch_Click(object sender, EventArgs e)
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

        private void btnRegexObjReplace_Click(object sender, EventArgs e)
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

        private void btnRegexObjSplit_Click(object sender, EventArgs e)
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

        private void textRegex_TextChanged(object sender, EventArgs e)
        {
            btnGetMatch_Click(sender, e);
        }

        public static class TextTool
        {
            /// <summary>
            /// Count occurrences of strings.
            /// </summary>
            public static int CountStringOccurrences(string text, string pattern)
            {
                // Loop through all instances of the string 'text'.
                int count = 0;
                int i = 0;
                while ((i = text.IndexOf(pattern, i)) != -1)
                {
                    i += pattern.Length;
                    count++;
                }
                return count;
            }
        }
    }
}
