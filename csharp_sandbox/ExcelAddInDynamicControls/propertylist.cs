// Copyright © Microsoft Corporation.  All Rights Reserved.
// This code released under the terms of the 
// Microsoft Public License (MS-PL, http://opensource.org/licenses/ms-pl.html.)

using System;
using System.Collections.Generic;

namespace ExcelAddInDynamicControls
{

    /// <summary>
    /// Class that stores a list of property values for a saved control.
    /// </summary>
    [Serializable]
    public class ControlProperties
    {
        [Serializable]
        public enum DynamicControlType { Button, CheckBox, ComboBox, RadioButton, UserControl, NamedRangeImpl, ListObjectImpl };

        /// <summary>
        /// The control's name.
        /// </summary>
        public string ControlName
        {
            get
            {
                return _name;
            }
            set
            {
                _name = value;
            }
        }

        /// <summary>
        /// The control's type.
        /// </summary>
        public DynamicControlType ControlType
        {
            get
            {
                return _type;
            }
            set
            {
                _type = value;
            }
        }

        /// <summary>
        /// The control's address.
        /// </summary>
        public string ControlAddress
        {
            get
            {
                return _address;
            }
            set
            {
                _address = value;
            }
        }

        /// <summary>
        /// The control's property list.
        /// </summary>
        public List<KeyValuePair<string, object>> PropertyList
        {
            get
            {
                return _list;
            }
        }

        /// <summary>
        /// The control's width in points.
        /// </summary>
        public double ControlWidth
        {
            get
            {
                return _width;
            }
            set
            {
                _width = value;
            }
        }

        /// <summary>
        /// The control's height in points.
        /// </summary>
        public double ControlHeight
        {
            get
            {
                return _height;
            }
            set
            {
                _height = value;
            }
        }

        /// <summary>
        /// The control's X coordinate in points.
        /// </summary>
        public double ControlX
        {
            get
            {
                return _x;
            }
            set
            {
                _x = value;
            }
        }

        /// <summary>
        /// The control's Y coordinate in points.
        /// </summary>
        public double ControlY
        {
            get
            {
                return _y;
            }
            set
            {
                _y = value;
            }
        }

        /// <summary>
        /// Default constructor - used for de-serialization.
        /// </summary>
        public ControlProperties()
        {
        }

        /// <summary>
        /// Constructor for host controls.
        /// </summary>
        /// <param name="name">Control's name</param>
        /// <param name="controlType">Control's type</param>
        /// <param name="address">Control's address (such as "A1:B2")</param>
        /// <param name="properties">List of control's properties to persist.</param>
        public ControlProperties(string name, DynamicControlType controlType, string address, params KeyValuePair<string, object>[] properties)
        {
            this._name = name;
            this._type = controlType;
            this._address = address;
            this._list = new List<KeyValuePair<string, object>>();

            this._list.AddRange(properties);
        }

        /// <summary>
        /// Constructor for Windows Forms controls.
        /// </summary>
        /// <param name="name">Control's name</param>
        /// <param name="controlType">Control's type</param>
        /// <param name="xCoordinate">Control's X coordinate in points</param>
        /// <param name="yCoordinate">Control's Y coordinate in points</param>
        /// <param name="width">Control's width in points</param>
        /// <param name="height">Control's height in points</param>
        /// <param name="properties">List of control's properties to persist.</param>
        public ControlProperties(string name, DynamicControlType controlType, double xCoordinate, double yCoordinate, double width, double height, params KeyValuePair<string, object>[] properties)
        {
            this._name = name;
            this._type = controlType;
            this._x = xCoordinate;
            this._y = yCoordinate;
            this._width = width;
            this._height = height;
            this._list = new List<KeyValuePair<string, object>>();

            this._list.AddRange(properties);
        }

        private string _name;
        private DynamicControlType _type;
        private string _address;

        private double _x;
        private double _y;

        private double _width;
        private double _height;

        private List<KeyValuePair<string, object>> _list;

    }
}
