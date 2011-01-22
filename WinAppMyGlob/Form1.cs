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
using System.Diagnostics;
using System.Threading;
using WinAppMyGlob.Properties;
using ClassLibraryFileGlobber;
using MySplash;

namespace WinAppMyGlob
{
    public partial class Form1 : Form
    {
        string[] myFiles = {
                            "Nothing to see here yet, do following steps first:",
                            "1. Set glob pattern in text box above, then...",
                            "2. Press the 'Glob' button for matching files." };
        DataTable dtRun = new DataTable();
        DataTable dtConfig = new DataTable();

        private List<string> anatomylist = new List<string>();
        private List<string> overlaylist = new List<string>();

        private Dictionary<string, string> dConfig = new Dictionary<string, string>();

        SplashScreenForm sf = new SplashScreenForm();

        public Form1()
        {
            this.Hide();
            Thread splashthread = new Thread(new ThreadStart(SplashScreen.ShowSplashScreen));
            splashthread.IsBackground = true;
            splashthread.Start();
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

            SplashScreen.UdpateStatusText("Loading Items!!!");
            Thread.Sleep(100);
            SplashScreen.UdpateStatusTextWithStatus("Success Message", TypeOfMessage.Success);
            //Thread.Sleep(100);
            //SplashScreen.UdpateStatusTextWithStatus("Warning Message", TypeOfMessage.Warning);

            //Thread.Sleep(100);
            //SplashScreen.UdpateStatusTextWithStatus("Error Message", TypeOfMessage.Error);
            //Thread.Sleep(100);
            //SplashScreen.UdpateStatusText("Testing Default Message Color");
            //Thread.Sleep(100);

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
                OleDbDataAdapter dbaRun = new OleDbDataAdapter("SELECT * FROM [run$]", dbConnection);
                OleDbDataAdapter dbaConfig = new OleDbDataAdapter("SELECT * FROM [config$]", dbConnection);
                dbaRun.Fill(dtRun);
                dbaConfig.Fill(dtConfig);
            }
            finally
            {
                dbConnection.Close();
            }

            // FIXME better way to do this LUT implementation?
            int count = 0;
            foreach (DataRow row in dtConfig.Rows)
            {
                dConfig.Add(row["KEY"].ToString(), row["VALUE"].ToString());
                count++;
            }

            SplashScreen.UdpateStatusText("Loaded " + count + " configuration items.");
            Thread.Sleep(2222);

            this.Show();

            // FIXME no need to "press the validate button" when we remove intermediate "Process" step
            btnValidate_Click(btnValidate, new System.EventArgs());

            SplashScreen.UdpateStatusText("Ready to process in MRIcroN, hit 'Process' button...");
            Thread.Sleep(2222);

            SplashScreen.CloseSplashScreen();
            this.Activate();

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
            foreach (DataRow row in dtRun.Rows)
            {
                string subject = row["Subject"].ToString();
                string session = row["Session"].ToString();
                string task = row["Task"].ToString();

                // FIXME refactor next 2 sets of similar code
                string keyOverlay = row["Overlay"].ToString();
                string overlay = "";
                if (dConfig.ContainsKey(keyOverlay))
                    overlay = dConfig[keyOverlay];
                string basepath = "";
                if (dConfig.ContainsKey("basePath"))
                    basepath = dConfig["basePath"];

                // build glob pattern to anatomical image
                globpat = @basepath + @"\" +
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
                        if (File.Exists(fi.DirectoryName + @"\" + overlay))
                        {
                            str = subject + " " + session + " " + task + " found both anatomy & overlay files.";
                            bln = true;
                            anatomylist.Add(fi.FullName);
                            overlaylist.Add(fi.DirectoryName + @"\" + overlay);
                        }
                        else
                        {
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
            // FIXME go back to source XLSM file and highlight rows that have FALSE for anat and/or overlay
            int count = 0;
            for (int i = 0; i < clbFiles.Items.Count; i++)
            {
                clbFiles.SetItemChecked(i, blnlist[i]);
                if (blnlist[i])
                    count++;
            }

            SplashScreen.UdpateStatusText(count + " of " + clbFiles.Items.Count + " sets of {anatomy background and overlay files} validated...");
            Thread.Sleep(2222);

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
                // FIXME make switches for MRIcroN call configurable in XLSM file
                string over = @" -c grayscale -o " + overlaylist[i] + @" -b 50";
                Process p = new Process();
                p.StartInfo.FileName = @dConfig["MRIcroNexe"];
                p.StartInfo.Arguments = anat + over;
                p.Start();

                this.Close();
            }
        }

    }
}

#region TODO
/* 
 * - splash screen init  message(s)
 * - see FIXME comments throughout
 */
#endregion