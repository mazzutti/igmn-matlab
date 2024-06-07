using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace InterfaceSRP
{
    public partial class IGMNInversionWindow : Form
    {

        #region Action declarations

        //The proper implementation of these actions will be found on the controller project (ControllerSRP)
        //Interface classes are unaware of program logic

        //Run the main algorithm
        public Action<string> RunIGMNInversion = null;

        //Get data for the input tables
        public Func<List<Tuple<bool, string>>> ReadWellList = null;
        public Func<List<Tuple<bool, string>>> ReadZoneList = null;
        public Func<List<string>> ReadWellsCrossZones = null;
        public Func<List<string>> ReadWellLogTypes = null;

        //Send selection data to the controller
        public Func<int, bool> FlipWellSelection = null;
        public Func<int, bool> FlipZoneSelection = null;

        //Delegate input interpretation
        public Func<object, DragEventArgs, Tuple<int, string, string>> InterpretCubeInput = null;
        public Func<object, DragEventArgs, string> InterpretRandomLineInput = null;

        //Add/Update output name/properties info
        public Action<int, string, int> UpdateOutputCube = null;
        public Action<float> UpdateGridSize = null;

        //Update the controller when an input/output row is deleted
        public Action<int> DeleteInputRow = null;
        public Action<int> DeleteOutputRow = null;

        #endregion

        #region Events that trigger Action calls
        private void RunButton_Click(object sender, EventArgs e)
        {
            //TODO: validate folder name
            RunIGMNInversion?.Invoke(OutputFolderTextBox.Text);
        }

        #endregion

        #region Auxiliary load/refresh functions
        private string CheckMark(bool isChecked)
        {
            return isChecked ? "✔" : "";
        }

        public void RefreshCellColors(DataGridView grid)
        {
            for (int i = 0; i < grid.RowCount; ++i)
            {
                //The table selection state (cell.Selected) is unreliable since it changes whenever the user clicks any cell
                //This function uses the text of the checkmark cell instead, which is handled only by the application

                DataGridViewCell cell = grid.Rows[i].Cells[0];
                if (((string)cell.Value).Length > 0)
                {
                    grid.Rows[i].DefaultCellStyle.BackColor = Color.FromArgb(unchecked((int)0xff40A0ff));
                    grid.Rows[i].DefaultCellStyle.ForeColor = Color.FromArgb(unchecked((int)0xffffffff));
                }
                else
                {
                    grid.Rows[i].DefaultCellStyle.BackColor = Color.FromArgb(unchecked((int)0xffffffff));
                    grid.Rows[i].DefaultCellStyle.ForeColor = Color.FromArgb(0);
                }
                grid.Rows[i].DefaultCellStyle.SelectionBackColor = grid.Rows[i].DefaultCellStyle.BackColor;
                grid.Rows[i].DefaultCellStyle.SelectionForeColor = grid.Rows[i].DefaultCellStyle.ForeColor;
            }
            grid.Invalidate();
        }

        private void RefreshTable(DataGridView grid, List<Tuple<bool, string>> itemList)
        {
            SuspendLayout();
            DataTable table = grid.DataSource as DataTable;
            table.Clear();
            foreach (var item in itemList)
            {
                DataRow newRow = table.NewRow();
                newRow[0] = CheckMark(item.Item1);
                newRow[1] = item.Item2;
                table.Rows.Add(newRow);
            }
            RefreshCellColors(grid);
            ResumeLayout();
        }

        public void RefreshWellTable()
        {
            if (ReadWellList == null) return;
            RefreshTable(WellTableView, ReadWellList());
        }

        public void RefreshZoneTable()
        {
            if (ReadZoneList == null) return;
            RefreshTable(ZoneTableView, ReadZoneList());
        }
        private void RefreshResultingSet()
        {
            if (ReadWellsCrossZones == null) return;
            ResultingSetTextBox.Text = String.Join("\r\n", ReadWellsCrossZones());
        }

        private void RefreshKnownOutputLogs()
        {
            if (ReadWellLogTypes == null) return;

            var logNames = ReadWellLogTypes();
            DataGridViewComboBoxColumn selectButton = OutputCubeTableView.Columns[0] as DataGridViewComboBoxColumn;
            var selectionValues = new Dictionary<string, int>();
            foreach (var logName in logNames)
            {
                selectionValues.Add(logName, selectionValues.Count);
            }
            selectButton.DataSource = new BindingSource(selectionValues, null);
            selectButton.DisplayMember = "Key";
            selectButton.ValueMember = "Value";
        }

        //Remotely Enable/Disable this window
        public void EnableWindow(bool enableMode)
        {
            TrainingDataInput.Enabled = enableMode;
            InputGroupBox.Enabled = enableMode;
            OutputGroupBox.Enabled = enableMode;
            OutputInfoBox.Enabled = enableMode;
            RunButton.Enabled = enableMode;
        }

        #endregion

        public IGMNInversionWindow()
        {
            InitializeComponent();

            #region Initialization of dynamic tables
            DataTable wellTable = new DataTable();
            wellTable.Columns.Add();
            wellTable.Columns.Add();
            WellTableView.DataSource = wellTable;
            WellTableView.Columns[0].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            WellTableView.Columns[0].Width = 24;
            WellTableView.CellMouseDown += ((sender, e) => SelectionTable_CellClick(FlipWellSelection, sender, e)); ;

            DataTable zoneTable = new DataTable();
            zoneTable.Columns.Add();
            zoneTable.Columns.Add();
            ZoneTableView.DataSource = zoneTable;
            ZoneTableView.Columns[0].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            ZoneTableView.Columns[0].Width = 24;
            ZoneTableView.CellMouseDown += ((sender, e) => SelectionTable_CellClick(FlipZoneSelection, sender, e));

            DataTable inputCubeTable = new DataTable();
            InputCubeTableView.Tag = new List<int>();
            inputCubeTable.Columns.Add();
            inputCubeTable.Columns.Add();
            InputCubeTableView.DataSource = inputCubeTable;
            DataGridViewButtonColumn inputDeleteButton = new DataGridViewButtonColumn
            {
                Text = "✖",
                UseColumnTextForButtonValue = true
            };
            InputCubeTableView.Columns.Add(inputDeleteButton);
            InputCubeTableView.CellToolTipTextNeeded += ((sender, e) =>
                e.ToolTipText = (e.ColumnIndex == 0) ? "Delete" : ((DataGridView)sender).Rows[e.RowIndex].Cells[e.ColumnIndex].Value?.ToString());
            InputCubeTableView.CellClick += InputCubeTableView_CellClick;
            InputCubeTableView.Columns[2].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            InputCubeTableView.Columns[2].Width = 24;
            InputCubeTableView.Columns[0].Resizable = DataGridViewTriState.True;
            InputCubeTableView.Columns[1].Resizable = DataGridViewTriState.False;
            InputCubeTableView.Columns[2].Resizable = DataGridViewTriState.False;

            DataTable outputCubeTable = new DataTable();
            outputCubeTable.Columns.Add();
            OutputCubeTableView.DataSource = outputCubeTable;
            DataGridViewComboBoxColumn selectButton = new DataGridViewComboBoxColumn();

            //Display a default text on cells that are used to add new values
            OutputCubeTableView.CellFormatting += ((sender, e) =>
                { if ((e.ColumnIndex == 0) && (e.Value == null)) { e.Value = "[Select Property]"; } });
            //Force cells to update the displayed value when the internal value changes
            OutputCubeTableView.CurrentCellDirtyStateChanged += ((sender, e) =>
            {
                DataGridView grid = sender as DataGridView;
                if (grid.IsCurrentCellDirty)
                {
                    if (grid.CurrentCell.ColumnIndex == 0)
                    {
                        if ((grid.CurrentCell != null) && (grid.CurrentCell.Value == null)) grid.CurrentCell.Value = 0;
                        grid.CommitEdit(DataGridViewDataErrorContexts.Commit);
                    }
                    else if ((grid.CurrentCell.ColumnIndex == 2) && (grid.CurrentCell.RowIndex != -1) && (grid.Rows[grid.CurrentCell.RowIndex].Cells[0].Value == null))
                    {
                        grid.CommitEdit(DataGridViewDataErrorContexts.Commit);
                    }
                }
            });
            //Force DataSource table to update when the cell is left while being edited
            OutputCubeTableView.CellLeave += ((sender, e) =>
            {
                DataGridView grid = sender as DataGridView;
                grid.NotifyCurrentCellDirty(true);
                if ((e.ColumnIndex != -1) && (e.RowIndex != -1) && (e.RowIndex < grid.Rows.Count - 1) && (grid.Rows[e.RowIndex].Cells[2].Value.GetType() == typeof(System.DBNull)))
                {
                    grid.BindingContext[grid.DataSource].CancelCurrentEdit();
                }
                else
                {
                    grid.BindingContext[grid.DataSource].EndCurrentEdit();
                }
            });

            OutputCubeTableView.CellValueChanged += OutputCubeComboBox_CellValueChanged;
            OutputCubeTableView.Columns.Add(selectButton);

            DataGridViewButtonColumn outputDeleteButton = new DataGridViewButtonColumn
            {
                Text = "✖",
                UseColumnTextForButtonValue = true
            };
            OutputCubeTableView.Columns.Add(outputDeleteButton);
            OutputCubeTableView.CellToolTipTextNeeded += ((sender, e) =>
                e.ToolTipText = (e.ColumnIndex == 1) ?
                ((e.RowIndex < ((DataGridView)sender).Rows.Count - 1) ? "Delete" : null) :
                ((e.ColumnIndex == 2) ? ((DataGridView)sender).Rows[e.RowIndex].Cells[e.ColumnIndex].Value?.ToString() : null));
            OutputCubeTableView.CellClick += OutputCubeTableView_CellClick;
            OutputCubeTableView.Columns[2].AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            OutputCubeTableView.Columns[2].Width = 24;
            OutputCubeTableView.Columns[0].Resizable = DataGridViewTriState.True;
            OutputCubeTableView.Columns[1].Resizable = DataGridViewTriState.False;
            OutputCubeTableView.Columns[2].Resizable = DataGridViewTriState.False;
            #endregion
        }

        private void SelectionTable_CellClick(Func<int, bool> selectionUpdate, object sender, DataGridViewCellMouseEventArgs e)
        {
            DataGridView grid = (DataGridView)sender;
            if (grid != null)
            {
                DataGridViewCell cell = grid.Rows[e.RowIndex].Cells[0];
                bool? newSelection;
                newSelection = selectionUpdate?.Invoke(e.RowIndex);
                if (newSelection.HasValue) cell.Value = CheckMark(newSelection.Value);
                RefreshCellColors(grid);
            }
            RefreshResultingSet();
        }

        private void InputCubeTableView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.ColumnIndex == 0)
            {
                DataGridView grid = (DataGridView)sender;
                if (grid != null)
                {
                    SuspendLayout();
                    DataTable table = grid.DataSource as DataTable;
                    DataRow toDelete = table.Rows[e.RowIndex];
                    toDelete.Delete();

                    int rowID = ((List<int>)grid.Tag).ElementAt(e.RowIndex);
                    ((List<int>)grid.Tag).RemoveAt(e.RowIndex);
                    DeleteInputRow?.Invoke(rowID);

                    ResumeLayout();
                }
            }
        }

        private void OutputCubeTableView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (sender is DataGridView grid)
            {
                //Custom mouse click handling to force the combo box to activate on the first click
                if ((e.ColumnIndex == 0) && (e.RowIndex != -1))
                {
                    grid.BeginEdit(true);
                    ((ComboBox)grid.EditingControl).DroppedDown = true;
                }

                //Handle the delete button
                if ((e.ColumnIndex == 1) && (e.RowIndex != -1))
                {
                    DataTable table = grid.DataSource as DataTable;
                    //Check if the user is not pressing the button at the row that adds a new entry
                    if (e.RowIndex < table.Rows.Count)
                    {
                        grid.EndEdit();
                        SuspendLayout();

                        table.Rows[e.RowIndex].Delete();

                        DeleteOutputRow?.Invoke(e.RowIndex);
                        ResumeLayout();
                    }
                }
            }
        }

        private void OutputCubeComboBox_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (sender is DataGridView grid)
            {
                var cellValue = grid.Rows[e.RowIndex].Cells[2].Value;
                string currentName = ((cellValue == null) || (cellValue.GetType() == typeof(System.DBNull))) ? "" : (string)cellValue;

                if (grid.Rows[e.RowIndex].Cells[0].Value == null)
                {
                    if (currentName == "") return;
                    grid.Rows[e.RowIndex].Cells[0].Value = 0;
                }

                grid.AllowUserToAddRows = true;
                var logDict = (Dictionary<string, int>)((BindingSource)((DataGridViewComboBoxColumn)grid.Columns[0]).DataSource).DataSource;
                var logDictEntry = logDict.ElementAt((int)grid.Rows[e.RowIndex].Cells[0].Value);
                int logIndex = logDictEntry.Value;

                //If the selected property has changed
                if (e.ColumnIndex == 0)
                {
                    string cubePrefix = "SRP_IGMNInversion_";
                    if ((currentName == "") || (currentName.StartsWith(cubePrefix)))
                    {
                        string logName = logDictEntry.Key;
                        string newCubeName = cubePrefix + logName;
                        //Defining the name here will trigger a new CellValueChanged event,
                        //we can return from here because this new event will call UpdateOutputCube
                        grid.Rows[e.RowIndex].Cells[2].Value = newCubeName;
                        return;
                    }
                }

                if (currentName != "")
                {
                    grid.Invalidate();
                    UpdateOutputCube?.Invoke(e.RowIndex, currentName, logIndex);
                }
            }
        }

        private void InputCubeDropTarget_DragDrop(object sender, DragEventArgs e)
        {
            if (InterpretCubeInput == null) return;
            var cubeData = InterpretCubeInput(sender, e);

            //cubeData.Item1 stores the id of the cube in the controller. -1 means the sent object was not a valid seismic cube
            if (cubeData.Item1 < 0) return;

            SuspendLayout();
            DataTable table = InputCubeTableView.DataSource as DataTable;
            DataRow newRow = table.NewRow();
            ((List<int>)InputCubeTableView.Tag).Add(cubeData.Item1);
            newRow[0] = cubeData.Item2;
            newRow[1] = cubeData.Item3;
            table.Rows.Add(newRow);
            InputCubeTableView.Invalidate();
            ResumeLayout();
        }

        private void RandLineDropTarget_DragDrop(object sender, DragEventArgs e)
        {
            string intersectionName = InterpretRandomLineInput?.Invoke(sender, e);
            if (intersectionName != null)
            {
                RandLineTextBox.Text = intersectionName;
                RandLineTextBox.Enabled = true;
                ClearIntersectionButton.Enabled = true;
            }
            else
            {
                RandLineTextBox.Text = "[None] (Generate full cubes)";
                RandLineTextBox.Enabled = false;
                ClearIntersectionButton.Enabled = false;
            }
        }

        private void GridSizeBox_ValueChanged(object sender, EventArgs e)
        {
            UpdateGridSize?.Invoke((float)((NumericUpDown)sender).Value);
        }

        private void ClearIntersectionButton_Click(object sender, EventArgs e)
        {
            RandLineDropTarget_DragDrop(null, null);
        }

        private void IGMNInversionWindow_Load(object sender, EventArgs e)
        {
            RefreshWellTable();
            RefreshZoneTable();
            RefreshKnownOutputLogs();
            UpdateGridSize?.Invoke((float)GridSizeBox.Value);
            RandLineDropTarget_DragDrop(null, null);
        }
    }

}
