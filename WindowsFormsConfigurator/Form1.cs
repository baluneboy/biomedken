using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.OleDb;
using WindowsFormsConfigurator.Properties;

namespace WindowsFormsConfigurator
{
    public partial class Form1 : Form
    {
        public bool UserClosing { get; set; }

        public Form1()
        {
            InitializeComponent();
            UserClosing = false;
            this.buttonExit.Click += new EventHandler(buttonExit_Click);
            this.FormClosing += new FormClosingEventHandler(Form1_FormClosing);
        }

        private void buttonOne_Click(object sender, EventArgs e)
        {

            DataTable fooData = new DataTable();
            OleDbConnection dbConnection = new OleDbConnection(@"Provider=Microsoft.ACE.OLEDB.12.0;"
                + @"Data Source=C:\temp\trashbar.xlsx;"
                + @"Extended Properties=""Excel 12.0;HDR=Yes;""");
            dbConnection.Open();
            try
            {
                OleDbDataAdapter dbAdapter = new OleDbDataAdapter("SELECT * FROM [foo$]", dbConnection);
                dbAdapter.Fill(fooData);
                dataGridView1.DataSource = fooData;
            }
            finally
            {
                dbConnection.Close();
            }

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            MessageBox.Show("you cannot make changes by clicking on datagrid (yet)");
        }

        private void buttonShowConfigPath_Click(object sender, EventArgs e)
        {
            MessageBox.Show(Properties.Settings.Default.SettingOne);
        }

        // how about the following?
        //http://msdn.microsoft.com/en-us/library/system.windows.forms.formclosingeventargs.aspx
        private void Form1_FormClosing(Object sender, FormClosingEventArgs e)
        {
            switch (e.CloseReason)
            {
                case CloseReason.ApplicationExitCall:
                    break;
                case CloseReason.FormOwnerClosing:
                    break;
                case CloseReason.MdiFormClosing:
                    break;
                case CloseReason.None:
                    break;
                case CloseReason.TaskManagerClosing:
                    break;
                case CloseReason.UserClosing:
                    if (UserClosing)
                    {
                        //what should happen if the user hit the button?
                        MessageBox.Show("user hit exit button");
                    }
                    else
                    {
                        //what should happen if the user hitted the x in the upper right corner?
                        MessageBox.Show("user hit X");
                    }
                    break;
                case CloseReason.WindowsShutDown:
                    break;
                default:
                    break;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //MessageBox.Show(Properties.Settings.Default.SettingOne);
        }

        private void buttonExit_Click(object sender, EventArgs e)
        {
            UserClosing = true;
            this.Close();
        }

    }
}