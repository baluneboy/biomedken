using System;
using System.IO;
using System.Windows.Forms;

namespace ClassLibraryFileGlobber
{
    // cleans path by adding trailing slash & offers
    // folder dialog when input string is not a dir
    public class BasePath
    {
        protected string fixPath;
        public string FixPath { get { return fixPath; } }

        public BasePath(string s, string prompt = "Select directory for basepath.")
        {
            fixPath = s.TrimEnd('\\');

            if (!Directory.Exists(fixPath))
            {
                FolderBrowserDialog fbd = new System.Windows.Forms.FolderBrowserDialog();

                // Set the help text description for the FolderBrowserDialog.
                fbd.Description = prompt;

                // Do not allow the user to create new files via the FolderBrowserDialog.
                fbd.ShowNewFolderButton = false;

                // Default to the My Documents folder.
                fbd.RootFolder = Environment.SpecialFolder.MyComputer;

                // Show dialog
                DialogResult result = fbd.ShowDialog();
                if (result == DialogResult.OK)
                    fixPath = fbd.SelectedPath.TrimEnd('\\');
                else
                {
                    MessageBox.Show("you hit cancel...oh well, let's see what happens...");
                    fixPath = "";
                }
            }

        }
    }

    // offers file dialog when input string is not a file
    public class ExeFile
    {
        protected string _theFile;
        public string FileName { get { return _theFile; } }
        
        public ExeFile(string s, string prompt = "Select the exe file.")
        {
            _theFile = @s;
            if (!File.Exists(_theFile))
            {
                OpenFileDialog ofd = new OpenFileDialog();

                // Set the help text description for the FolderBrowserDialog.
                ofd.Title = prompt;
                ofd.InitialDirectory = Environment.CurrentDirectory; // @"c:\";
                ofd.Filter = "exe files (*.exe)|*.exe|bat file (*.bat)|*.bat|All files (*.*)|*.*";
                ofd.FilterIndex = 1;
                ofd.RestoreDirectory = true;

                // Show dialog
                DialogResult result = ofd.ShowDialog();
                if (result == DialogResult.OK)
                    _theFile = ofd.FileName;
                else
                {
                    MessageBox.Show("you hit cancel...oh well, let's see what happens...");
                    _theFile = "";
                }
            }

        }
    }
}



