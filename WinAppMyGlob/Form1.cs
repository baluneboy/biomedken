﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.OleDb;
using System.IO;
using System.Diagnostics;
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

        private List<string> anatomylist = new List<string>();
        private List<string> overlaylist = new List<string>();

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
                    "SELECT * FROM [run$]", dbConnection);
                dbAdapter.Fill(dtConfig);
            }
            finally
            {
                dbConnection.Close();
            }

            // press the validate button
            btnValidate_Click(btnValidate, new System.EventArgs());
            tssMessage.Text = @"checking for file validation done";

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


        private void btnValidate_Click(object sender, EventArgs e)
        {

            // Iterate over config's data table contents to glob & process
            List<string> filelist = new List<string>();
            List<Boolean> blnlist = new List<Boolean>();
            string globpat;
            string str = "unknown status";
            Boolean bln = false;
            foreach (DataRow row in dtConfig.Rows)
            {
                string subject = row["Subject"].ToString();
                string session = row["Session"].ToString();
                string task = row["Task"].ToString();

                // FIXME, did some convenience hard-coding here for rough prototype
                // with overlay & basepath

                //string overlay = row["Overlay"].ToString();
                string overlay = @".\masked_roi98_mniwholebrain_fromspm_wroi99_wholecube_both_p-overlay_adathreshold_remap_clustercorrected.hdr";

                // build glob pattern to anatomical image
                //globpat = row["Basepath"].ToString() + @"\" +
                globpat = @"y:\adat" + @"\" +
                          subject + @"\" +
                          session + @"\" +
                          "study_*" + @"\" + "results" + @"\" +
                          task + @"\" +
                          "w2*WHOLEHEAD*.hdr";

                // glob for matching files
                tssMessage.Text = @"Running FileGlobber on " + globpat;
                FileGlobber fg = new FileGlobber(globpat);

                // if exactly one anat header file found, then check; otherwise uncheck
                if (fg.MatchCount == 1)
                {
                    // FIXME better method for add single FileInfo item to list!?
                    tssMessage.Text = @"Checking for overlay file wrt " + globpat;
                    foreach (var fi in fg.MatchingFiles)
                    {
                        if (File.Exists(fi.DirectoryName + @"\" + overlay))
                        {
                            //MessageBox.Show(fi.DirectoryName + @"\" + overlay + " exists.");
                            //str = fi.FullName;
                            str = subject + " " + session + " " + task + " found both anatomy & overlay files.";
                            bln = true;
                            anatomylist.Add(fi.FullName);
                            overlaylist.Add(fi.DirectoryName + @"\" + overlay);
                        }
                        else
                        {
                            //MessageBox.Show(fi.DirectoryName + @"\" + overlay + " does NOT exist!");
                            str = subject + " " + session + " " + task + " found no overlay file.";
                            bln = false;
                        }
                    }
                }
                else
                {
                    str = subject + " " + session + " " + task + " found no anatomy file.";
                    bln = false;
                }
                filelist.Add(str);
                blnlist.Add(bln);
            }
            clbFiles.DataSource = filelist;
            for (int i = 0; i < clbFiles.Items.Count; i++)
                clbFiles.SetItemChecked(i, blnlist[i]);

            // enable processing
            btnProcess.Enabled = true;

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

        private void btnProcess_Click(object sender, EventArgs e)
        {
            for (int i = 0; i < anatomylist.Count; i++)
            {
                string anat = anatomylist[i];
                string over = @" -c grayscale -o " + overlaylist[i] + @" -b 50";
                //MessageBox.Show(anatomylist[i] + "\n" + overlaylist[i]);
                Process p = new Process();
                p.StartInfo.FileName = @"C:\Program Files\mricron\MRIcroN.exe"; // FIXME
                p.StartInfo.Arguments = anat + over;
                p.Start();

                // wait a few seconds, before close this form
                //System.Threading.Thread.Sleep(1000);

                this.Close();
            }
        }

    }
}

/* 
 * TODO
 * - IMPROVE "basepath" & "overlay" [relative path/pattern] handling
 * - implement LUT (via Key/Val pairs) for excel, like: subject, session, task, overlay
 * - make it so that path to MRIcroN is discoverable, not hard-coded
 */