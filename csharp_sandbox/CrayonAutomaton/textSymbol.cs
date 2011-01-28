using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CrayonAutomaton {
    public partial class textSymbol : Form {
        /// <summary>Get the symbols selected by the user</summary>
        public string Symbols { get { return addedSymbolsText.Text; } }

        Bitmap symbolImage = null;
        const int fontEM = 30;
        const int fontWidth = 25;
        Font font;
        Font largerFont;
        decimal perWidth;
        decimal charCol = -1;   //there's a reason i can't remember to not use a Point
        decimal charRow = -1;
        decimal oldCharCol = -1;
        decimal oldCharRow = -1;
        string curSymbol = "";
        GraphicsPath hoverRect = new GraphicsPath();

        public textSymbol(Font font) {
            InitializeComponent();
            this.font = font;
            largeSymbolLabel.Font = new Font(font.FontFamily, largeSymbolLabel.Height - 20);
            largerFont = new Font(font.FontFamily, fontEM - 10);
            perWidth = Math.Floor((decimal)(symbolBox.Width / fontWidth));
            symbolBox.Paint += new PaintEventHandler(symbolBox_Paint);
            symbolBox.MouseMove += new MouseEventHandler(symbolBox_MouseMove);
            symbolBox.MouseLeave += new EventHandler(symbolBox_MouseLeave);
            symbolBox.DoubleClick += new EventHandler(symbolBox_DoubleClick);
            Text += string.Format(" ({0})", Font.Name);
        }

        void symbolBox_DoubleClick(object sender, EventArgs e) {
            addedSymbolsText.Text += curSymbol;
        }

        void symbolBox_MouseLeave(object sender, EventArgs e) {
            charCol = -1;
            charRow = -1;
            largeSymbolLabel.Text = "";
            symbolBox.Invalidate();
        }

        void symbolBox_MouseMove(object sender, MouseEventArgs e) {
            charCol = Math.Floor((decimal)(e.X / fontWidth));
            charRow = Math.Floor((decimal)(e.Y / fontEM));
            if ((charCol != oldCharCol) || (charRow != oldCharRow)) {
                curSymbol = characterFromPoint(charCol, charRow);
                largeSymbolLabel.Text = curSymbol;
                charInfoLabel.Text = string.Format("U+{0:x4}", (int)(charRow * perWidth + charCol));
                oldCharCol = charCol;
                oldCharRow = charRow;
                symbolBox.Invalidate();
            }
        }

        void symbolBox_Paint(object sender, PaintEventArgs e) {
            /* Create background image if it needs to be */
            if (symbolImage == null) {
                createSymbolImage(e.Graphics);
                symbolBox.BackgroundImage = symbolImage;
            }

            /* Draw hover rectangle */
            e.Graphics.DrawImageUnscaled(symbolImage, new Point(0, 0));
            if ((charCol > -1) && (charRow > -1)) {
                hoverRect.Reset();
                hoverRect.AddRectangle(new Rectangle(
                    (int)(charCol * fontWidth),
                    (int)(charRow * fontEM),
                    fontWidth,
                    fontEM));
                e.Graphics.DrawPath(Pens.Red, hoverRect);
            }
        }
        string characterFromPoint(decimal x, decimal y) { return characterFromPoint((int)x, (int)y); }
        string characterFromPoint(int x, int y) {
            return intToCharString(y * perWidth + x);
        }
        string intToCharString(decimal num) { return intToCharString((int)num); }
        string intToCharString(int num) {
            return ((char)num).ToString();
        }
        void createSymbolImage(Graphics g) {
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            decimal height = 255 / perWidth;
            symbolImage = new Bitmap((int)(perWidth * fontWidth), (int)(fontEM * height), g);
            Graphics symbolImageGraphics = Graphics.FromImage(symbolImage);
            StringFormat format = new StringFormat(StringFormatFlags.DisplayFormatControl | StringFormatFlags.NoWrap);
            format.Alignment = StringAlignment.Center;
            format.LineAlignment = StringAlignment.Center;
            for (int i = 0; i <= 255; i++)
                symbolImageGraphics.DrawString(
                    intToCharString(i),
                    largerFont, Brushes.Black,
                    new RectangleF(
                        (float)(i % perWidth) * fontWidth,
                        fontEM * (float)Math.Floor(i / perWidth),
                        fontWidth, fontEM),
                    format);
            symbolBox.Height = symbolImage.Height;
        }
    }
}
