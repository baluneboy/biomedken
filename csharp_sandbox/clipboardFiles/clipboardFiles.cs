using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Net.Mail;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using System.Text.RegularExpressions;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Linq;

namespace clipboardFiles
{
    public class clipboardFiles
    {
        public static String rx = "";
        public static String fileList = "";

        [STAThread]
        public static void Main(String[] args)
        {

            rxForm getExt = new rxForm(); // use a form where args input gets set as initial value in textSubject.text
            getExt.ShowDialog();
            if(rx.Equals("CANCEL"))
            {
                Environment.Exit(1);
            }
            //System.Windows.Forms.MessageBox.Show("input is: " + rx);
            DirectoryInfo root = new DirectoryInfo(@String.Join(" ", args));
            //String r =@".+\."+ext+"$"; //KH commented out..."it's not just about the extension anymore"
            String r = @rx;
            snagFiles(root,r);
            if (fileList.Equals(""))
            {
                System.Windows.Forms.MessageBox.Show("Nothing found.\nPerhaps the regexp was not quite right?", "Files not found", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);
            }
            else
            {
                Clipboard.SetDataObject(fileList, true);
            }
        }

        public static void snagFiles(DirectoryInfo dir, String r)
        {
            FileInfo[] dirFiles = dir.GetFiles();
            foreach (FileInfo F in dirFiles)
            {   
                if(Regex.IsMatch(F.Name,r,RegexOptions.IgnoreCase))
                {
                    fileList += F.FullName + "\r\n";
                }
            }
            foreach (DirectoryInfo childDir in dir.GetDirectories())
            {
                snagFiles(childDir,r);
            }
        }
    }
}