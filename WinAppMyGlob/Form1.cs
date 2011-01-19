using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.OleDb;
using System.IO;
using WinAppMyGlob.Properties;
using ClassLibraryFileGlobber;

namespace WinAppMyGlob
{
    public partial class Form1 : Form
    {
        string[] myFiles = {
                            "Nothing to see here yet, do following steps first:",
                            "1. Set glob pattern in text box above, then...",
                            "2. Press the 'Glob' button for matching files." };
        
        DataTable dtConfig = new DataTable();

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.clbFiles.DataSource = myFiles;

            string ConfigFile = System.IO.Path.Combine(Properties.Settings.Default.ConfigPath,
                Properties.Settings.Default.ConfigFile);
            OleDbConnection dbConnection = new OleDbConnection(
                @"Provider=Microsoft.ACE.OLEDB.12.0;"
                + @"Data Source=" + ConfigFile + ";"
                + @"Extended Properties=""Excel 12.0;HDR=Yes;""");
            dbConnection.Open();
            try
            {
                OleDbDataAdapter dbAdapter = new OleDbDataAdapter(
                    "SELECT * FROM [config$]", dbConnection);
                dbAdapter.Fill(dtConfig);
            }
            finally
            {
                dbConnection.Close();
            }

        }

        private void txtGlobPattern_TextChanged(object sender, EventArgs e)
        {

        }

        private void btnGlob_Click(object sender, EventArgs e)
        {
            // message
            clbFiles.DataSource = new string[] { "Now gathering files that match..." };

            // get glob pattern
            string globPattern = txtGlobPattern.Text;
            FileGlobber fg = new FileGlobber(globPattern);

            // clear & populate listbox
            clbFiles.DataSource = null;
            clbFiles.DataSource = fg.MatchingFiles.ToList();

        }

        private void clbFiles_DataSourceChanged(object sender, EventArgs e)
        {
            /*
			*The following code is required to remove existing items from the
            *Items collection when the DataSource is set to null.
			*/

            ListBox ctlLIST = (ListBox)sender;
            if (ctlLIST.DataSource == null)
                ctlLIST.Items.Clear();
        }


        private void btnProcess_Click(object sender, EventArgs e)
        {
            //// Determine if there are any items checked.
            //if (clbFiles.CheckedItems.Count != 0)
            //{
            //    // If so, loop through all checked items and print results.
            //    string s = "";
            //    for (int x = 0; x <= clbFiles.CheckedItems.Count - 1; x++)
            //    {
            //        s = s + "Checked Item " + (x + 1).ToString() + " = " + clbFiles.CheckedItems[x].ToString() + "\n";
            //    }
            //    MessageBox.Show(s);
            //}

            // Iterate over config's data table contents to glob & process
            List<string> filelist = new List<string>();
            List<Boolean> blnlist = new List<Boolean>();
            string globpat;
            foreach (DataRow row in dtConfig.Rows)
            {
                string subject = row["Subject"].ToString();
                string session = row["Session"].ToString();
                string task = row["Task"].ToString();

                // build glob pattern to anatomical image
                globpat = row["Basepath"].ToString() + @"\" +
                          subject + @"\" +
                          session + @"\" +
                          "study_*" + @"\" + "results" + @"\" +
                          task + @"\" +
                          "w2*WHOLEHEAD*.hdr";

                // glob for matching files
                FileGlobber fg = new FileGlobber(globpat);

                // if exactly one anat header file found, then check; otherwise uncheck
                if (fg.MatchCount == 1)
                {
                    // FIXME better method for add single FileInfo item to list!?
                    foreach (var fi in fg.MatchingFiles)
                    {
                        filelist.Add(fi.FullName);
                        blnlist.Add(true);
                    }
                }
                else
                {
                    filelist.Add("No anat file for " + subject + " " + session + " " + task);
                    blnlist.Add(false);
                }
            }
            clbFiles.DataSource = filelist;
            for (int i = 0; i < clbFiles.Items.Count; i++)
                clbFiles.SetItemChecked(i, blnlist[i]);
        }

        private void clbFiles_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnSelectAll_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < clbFiles.Items.Count; i++)
                clbFiles.SetItemChecked(i, true);
        }

        private void btnUnselectAll_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < clbFiles.Items.Count; i++)
                clbFiles.SetItemChecked(i, false);
        }

    }
}
