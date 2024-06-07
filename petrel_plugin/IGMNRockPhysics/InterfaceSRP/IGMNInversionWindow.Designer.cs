
namespace InterfaceSRP
{
    partial class IGMNInversionWindow
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle10 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle11 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle12 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(IGMNInversionWindow));
            this.RunButton = new Slb.Ocean.Petrel.UI.Controls.BasicButton();
            this.TrainingDataInput = new System.Windows.Forms.GroupBox();
            this.GridSizeBox = new System.Windows.Forms.NumericUpDown();
            this.label1 = new System.Windows.Forms.Label();
            this.ResultingSetGroupBox = new System.Windows.Forms.GroupBox();
            this.ResultingSetTextBox = new System.Windows.Forms.TextBox();
            this.ZonesGroupBox = new System.Windows.Forms.GroupBox();
            this.ZoneTableView = new System.Windows.Forms.DataGridView();
            this.WellsGroupBox = new System.Windows.Forms.GroupBox();
            this.WellTableView = new System.Windows.Forms.DataGridView();
            this.InputGroupBox = new System.Windows.Forms.GroupBox();
            this.InputCubeTableView = new System.Windows.Forms.DataGridView();
            this.InputCubeDropTarget = new Slb.Ocean.Petrel.UI.DropTarget();
            this.OutputGroupBox = new System.Windows.Forms.GroupBox();
            this.OutputCubeTableView = new System.Windows.Forms.DataGridView();
            this.IntersectionsBox = new System.Windows.Forms.GroupBox();
            this.ClearIntersectionButton = new Slb.Ocean.Petrel.UI.Controls.BasicButton();
            this.RandLineTextBox = new System.Windows.Forms.TextBox();
            this.RandLineDropTarget = new Slb.Ocean.Petrel.UI.DropTarget();
            this.OutputFolderTextBox = new System.Windows.Forms.TextBox();
            this.OutputFolderLabel = new System.Windows.Forms.Label();
            this.OutputInfoBox = new System.Windows.Forms.GroupBox();
            this.TrainingDataInput.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.GridSizeBox)).BeginInit();
            this.ResultingSetGroupBox.SuspendLayout();
            this.ZonesGroupBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ZoneTableView)).BeginInit();
            this.WellsGroupBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.WellTableView)).BeginInit();
            this.InputGroupBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.InputCubeTableView)).BeginInit();
            this.OutputGroupBox.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.OutputCubeTableView)).BeginInit();
            this.IntersectionsBox.SuspendLayout();
            this.OutputInfoBox.SuspendLayout();
            this.SuspendLayout();
            // 
            // RunButton
            // 
            this.RunButton.BackColor = System.Drawing.Color.White;
            this.RunButton.Location = new System.Drawing.Point(827, 1360);
            this.RunButton.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.RunButton.Name = "RunButton";
            this.RunButton.Size = new System.Drawing.Size(160, 40);
            this.RunButton.TabIndex = 0;
            this.RunButton.Text = "Run";
            this.RunButton.UseVisualStyleBackColor = false;
            this.RunButton.Click += new System.EventHandler(this.RunButton_Click);
            // 
            // TrainingDataInput
            // 
            this.TrainingDataInput.Controls.Add(this.GridSizeBox);
            this.TrainingDataInput.Controls.Add(this.label1);
            this.TrainingDataInput.Controls.Add(this.ResultingSetGroupBox);
            this.TrainingDataInput.Controls.Add(this.ZonesGroupBox);
            this.TrainingDataInput.Controls.Add(this.WellsGroupBox);
            this.TrainingDataInput.Location = new System.Drawing.Point(16, 16);
            this.TrainingDataInput.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.TrainingDataInput.Name = "TrainingDataInput";
            this.TrainingDataInput.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.TrainingDataInput.Size = new System.Drawing.Size(971, 476);
            this.TrainingDataInput.TabIndex = 1;
            this.TrainingDataInput.TabStop = false;
            this.TrainingDataInput.Text = "Training Data Input";
            // 
            // GridSizeBox
            // 
            this.GridSizeBox.DecimalPlaces = 2;
            this.GridSizeBox.Increment = new decimal(new int[] {
            1,
            0,
            0,
            131072});
            this.GridSizeBox.Location = new System.Drawing.Point(132, 429);
            this.GridSizeBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.GridSizeBox.Maximum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.GridSizeBox.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            131072});
            this.GridSizeBox.Name = "GridSizeBox";
            this.GridSizeBox.Size = new System.Drawing.Size(141, 20);
            this.GridSizeBox.TabIndex = 7;
            this.GridSizeBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.GridSizeBox.Value = new decimal(new int[] {
            5,
            0,
            0,
            131072});
            this.GridSizeBox.ValueChanged += new System.EventHandler(this.GridSizeBox_ValueChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 435);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(52, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Grid Size:";
            // 
            // ResultingSetGroupBox
            // 
            this.ResultingSetGroupBox.Controls.Add(this.ResultingSetTextBox);
            this.ResultingSetGroupBox.Location = new System.Drawing.Point(576, 35);
            this.ResultingSetGroupBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ResultingSetGroupBox.Name = "ResultingSetGroupBox";
            this.ResultingSetGroupBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ResultingSetGroupBox.Size = new System.Drawing.Size(387, 387);
            this.ResultingSetGroupBox.TabIndex = 2;
            this.ResultingSetGroupBox.TabStop = false;
            this.ResultingSetGroupBox.Text = "Resulting Set";
            // 
            // ResultingSetTextBox
            // 
            this.ResultingSetTextBox.ImeMode = System.Windows.Forms.ImeMode.On;
            this.ResultingSetTextBox.Location = new System.Drawing.Point(11, 35);
            this.ResultingSetTextBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ResultingSetTextBox.Multiline = true;
            this.ResultingSetTextBox.Name = "ResultingSetTextBox";
            this.ResultingSetTextBox.ReadOnly = true;
            this.ResultingSetTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ResultingSetTextBox.Size = new System.Drawing.Size(367, 340);
            this.ResultingSetTextBox.TabIndex = 0;
            // 
            // ZonesGroupBox
            // 
            this.ZonesGroupBox.Controls.Add(this.ZoneTableView);
            this.ZonesGroupBox.Location = new System.Drawing.Point(292, 35);
            this.ZonesGroupBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ZonesGroupBox.Name = "ZonesGroupBox";
            this.ZonesGroupBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ZonesGroupBox.Size = new System.Drawing.Size(275, 387);
            this.ZonesGroupBox.TabIndex = 1;
            this.ZonesGroupBox.TabStop = false;
            this.ZonesGroupBox.Text = "Zones";
            // 
            // ZoneTableView
            // 
            this.ZoneTableView.AllowUserToAddRows = false;
            this.ZoneTableView.AllowUserToDeleteRows = false;
            this.ZoneTableView.AllowUserToResizeColumns = false;
            this.ZoneTableView.AllowUserToResizeRows = false;
            this.ZoneTableView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.ZoneTableView.BackgroundColor = System.Drawing.Color.White;
            this.ZoneTableView.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.ZoneTableView.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.None;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.ZoneTableView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.ZoneTableView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.ZoneTableView.ColumnHeadersVisible = false;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.ZoneTableView.DefaultCellStyle = dataGridViewCellStyle2;
            this.ZoneTableView.GridColor = System.Drawing.Color.White;
            this.ZoneTableView.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.ZoneTableView.Location = new System.Drawing.Point(11, 35);
            this.ZoneTableView.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ZoneTableView.Name = "ZoneTableView";
            this.ZoneTableView.ReadOnly = true;
            this.ZoneTableView.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.ZoneTableView.RowHeadersDefaultCellStyle = dataGridViewCellStyle3;
            this.ZoneTableView.RowHeadersVisible = false;
            this.ZoneTableView.RowHeadersWidth = 51;
            this.ZoneTableView.RowTemplate.Height = 24;
            this.ZoneTableView.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ZoneTableView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.ZoneTableView.ShowCellErrors = false;
            this.ZoneTableView.ShowCellToolTips = false;
            this.ZoneTableView.Size = new System.Drawing.Size(253, 341);
            this.ZoneTableView.TabIndex = 1;
            // 
            // WellsGroupBox
            // 
            this.WellsGroupBox.Controls.Add(this.WellTableView);
            this.WellsGroupBox.Location = new System.Drawing.Point(11, 35);
            this.WellsGroupBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.WellsGroupBox.Name = "WellsGroupBox";
            this.WellsGroupBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.WellsGroupBox.Size = new System.Drawing.Size(275, 387);
            this.WellsGroupBox.TabIndex = 0;
            this.WellsGroupBox.TabStop = false;
            this.WellsGroupBox.Text = "Wells";
            // 
            // WellTableView
            // 
            this.WellTableView.AllowUserToAddRows = false;
            this.WellTableView.AllowUserToDeleteRows = false;
            this.WellTableView.AllowUserToResizeColumns = false;
            this.WellTableView.AllowUserToResizeRows = false;
            this.WellTableView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.WellTableView.BackgroundColor = System.Drawing.Color.White;
            this.WellTableView.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.WellTableView.CellBorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.None;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.WellTableView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.WellTableView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.WellTableView.ColumnHeadersVisible = false;
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.BackColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle5.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle5.SelectionBackColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.SelectionForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle5.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.WellTableView.DefaultCellStyle = dataGridViewCellStyle5;
            this.WellTableView.GridColor = System.Drawing.Color.White;
            this.WellTableView.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.WellTableView.Location = new System.Drawing.Point(11, 35);
            this.WellTableView.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.WellTableView.Name = "WellTableView";
            this.WellTableView.ReadOnly = true;
            this.WellTableView.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle6.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle6.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.WellTableView.RowHeadersDefaultCellStyle = dataGridViewCellStyle6;
            this.WellTableView.RowHeadersVisible = false;
            this.WellTableView.RowHeadersWidth = 51;
            this.WellTableView.RowTemplate.Height = 24;
            this.WellTableView.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.WellTableView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.WellTableView.ShowCellErrors = false;
            this.WellTableView.ShowCellToolTips = false;
            this.WellTableView.Size = new System.Drawing.Size(253, 341);
            this.WellTableView.TabIndex = 0;
            // 
            // InputGroupBox
            // 
            this.InputGroupBox.Controls.Add(this.InputCubeTableView);
            this.InputGroupBox.Controls.Add(this.InputCubeDropTarget);
            this.InputGroupBox.Location = new System.Drawing.Point(16, 503);
            this.InputGroupBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.InputGroupBox.Name = "InputGroupBox";
            this.InputGroupBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.InputGroupBox.Size = new System.Drawing.Size(971, 308);
            this.InputGroupBox.TabIndex = 2;
            this.InputGroupBox.TabStop = false;
            this.InputGroupBox.Text = "Input Properties";
            // 
            // InputCubeTableView
            // 
            this.InputCubeTableView.AllowUserToAddRows = false;
            this.InputCubeTableView.AllowUserToDeleteRows = false;
            this.InputCubeTableView.AllowUserToResizeRows = false;
            this.InputCubeTableView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            dataGridViewCellStyle7.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle7.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle7.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle7.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle7.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle7.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle7.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.InputCubeTableView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle7;
            this.InputCubeTableView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.InputCubeTableView.ColumnHeadersVisible = false;
            dataGridViewCellStyle8.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(240)))), ((int)(((byte)(210)))));
            dataGridViewCellStyle8.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle8.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle8.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(240)))), ((int)(((byte)(210)))));
            dataGridViewCellStyle8.SelectionForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle8.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.InputCubeTableView.DefaultCellStyle = dataGridViewCellStyle8;
            this.InputCubeTableView.GridColor = System.Drawing.SystemColors.ControlDarkDark;
            this.InputCubeTableView.Location = new System.Drawing.Point(68, 35);
            this.InputCubeTableView.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.InputCubeTableView.Name = "InputCubeTableView";
            this.InputCubeTableView.ReadOnly = true;
            dataGridViewCellStyle9.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle9.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle9.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle9.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle9.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle9.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle9.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.InputCubeTableView.RowHeadersDefaultCellStyle = dataGridViewCellStyle9;
            this.InputCubeTableView.RowHeadersVisible = false;
            this.InputCubeTableView.RowHeadersWidth = 51;
            this.InputCubeTableView.RowTemplate.Height = 24;
            this.InputCubeTableView.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.InputCubeTableView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.InputCubeTableView.Size = new System.Drawing.Size(895, 264);
            this.InputCubeTableView.TabIndex = 1;
            // 
            // InputCubeDropTarget
            // 
            this.InputCubeDropTarget.AllowDrop = true;
            this.InputCubeDropTarget.Location = new System.Drawing.Point(8, 35);
            this.InputCubeDropTarget.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.InputCubeDropTarget.Name = "InputCubeDropTarget";
            this.InputCubeDropTarget.Size = new System.Drawing.Size(52, 264);
            this.InputCubeDropTarget.TabIndex = 0;
            this.InputCubeDropTarget.DragDrop += new System.Windows.Forms.DragEventHandler(this.InputCubeDropTarget_DragDrop);
            // 
            // OutputGroupBox
            // 
            this.OutputGroupBox.Controls.Add(this.OutputCubeTableView);
            this.OutputGroupBox.Location = new System.Drawing.Point(16, 817);
            this.OutputGroupBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputGroupBox.Name = "OutputGroupBox";
            this.OutputGroupBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputGroupBox.Size = new System.Drawing.Size(971, 309);
            this.OutputGroupBox.TabIndex = 3;
            this.OutputGroupBox.TabStop = false;
            this.OutputGroupBox.Text = "Output Properties";
            // 
            // OutputCubeTableView
            // 
            this.OutputCubeTableView.AllowUserToDeleteRows = false;
            this.OutputCubeTableView.AllowUserToResizeRows = false;
            this.OutputCubeTableView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            dataGridViewCellStyle10.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle10.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle10.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle10.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle10.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle10.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle10.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.OutputCubeTableView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle10;
            this.OutputCubeTableView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.OutputCubeTableView.ColumnHeadersVisible = false;
            dataGridViewCellStyle11.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle11.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(240)))), ((int)(((byte)(210)))));
            dataGridViewCellStyle11.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle11.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle11.SelectionBackColor = System.Drawing.SystemColors.MenuHighlight;
            dataGridViewCellStyle11.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle11.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.OutputCubeTableView.DefaultCellStyle = dataGridViewCellStyle11;
            this.OutputCubeTableView.EditMode = System.Windows.Forms.DataGridViewEditMode.EditOnEnter;
            this.OutputCubeTableView.Location = new System.Drawing.Point(8, 35);
            this.OutputCubeTableView.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputCubeTableView.Name = "OutputCubeTableView";
            dataGridViewCellStyle12.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle12.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle12.Font = new System.Drawing.Font("Microsoft Sans Serif", 4.125F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle12.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle12.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle12.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle12.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.OutputCubeTableView.RowHeadersDefaultCellStyle = dataGridViewCellStyle12;
            this.OutputCubeTableView.RowHeadersVisible = false;
            this.OutputCubeTableView.RowHeadersWidth = 51;
            this.OutputCubeTableView.RowTemplate.Height = 24;
            this.OutputCubeTableView.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.OutputCubeTableView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.OutputCubeTableView.Size = new System.Drawing.Size(955, 264);
            this.OutputCubeTableView.TabIndex = 2;
            // 
            // IntersectionsBox
            // 
            this.IntersectionsBox.Controls.Add(this.ClearIntersectionButton);
            this.IntersectionsBox.Controls.Add(this.RandLineTextBox);
            this.IntersectionsBox.Controls.Add(this.RandLineDropTarget);
            this.IntersectionsBox.Location = new System.Drawing.Point(8, 33);
            this.IntersectionsBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.IntersectionsBox.Name = "IntersectionsBox";
            this.IntersectionsBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.IntersectionsBox.Size = new System.Drawing.Size(955, 83);
            this.IntersectionsBox.TabIndex = 4;
            this.IntersectionsBox.TabStop = false;
            this.IntersectionsBox.Text = "General Intersections";
            // 
            // ClearIntersectionButton
            // 
            this.ClearIntersectionButton.BackColor = System.Drawing.Color.White;
            this.ClearIntersectionButton.Enabled = false;
            this.ClearIntersectionButton.Location = new System.Drawing.Point(781, 33);
            this.ClearIntersectionButton.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.ClearIntersectionButton.Name = "ClearIntersectionButton";
            this.ClearIntersectionButton.Size = new System.Drawing.Size(160, 37);
            this.ClearIntersectionButton.TabIndex = 4;
            this.ClearIntersectionButton.Text = "Clear";
            this.ClearIntersectionButton.UseVisualStyleBackColor = false;
            this.ClearIntersectionButton.Click += new System.EventHandler(this.ClearIntersectionButton_Click);
            // 
            // RandLineTextBox
            // 
            this.RandLineTextBox.Location = new System.Drawing.Point(107, 36);
            this.RandLineTextBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.RandLineTextBox.Name = "RandLineTextBox";
            this.RandLineTextBox.ReadOnly = true;
            this.RandLineTextBox.Size = new System.Drawing.Size(665, 20);
            this.RandLineTextBox.TabIndex = 10;
            // 
            // RandLineDropTarget
            // 
            this.RandLineDropTarget.AllowDrop = true;
            this.RandLineDropTarget.Location = new System.Drawing.Point(9, 33);
            this.RandLineDropTarget.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.RandLineDropTarget.Name = "RandLineDropTarget";
            this.RandLineDropTarget.Size = new System.Drawing.Size(89, 40);
            this.RandLineDropTarget.TabIndex = 2;
            this.RandLineDropTarget.DragDrop += new System.Windows.Forms.DragEventHandler(this.RandLineDropTarget_DragDrop);
            // 
            // OutputFolderTextBox
            // 
            this.OutputFolderTextBox.Location = new System.Drawing.Point(228, 171);
            this.OutputFolderTextBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputFolderTextBox.Name = "OutputFolderTextBox";
            this.OutputFolderTextBox.Size = new System.Drawing.Size(733, 20);
            this.OutputFolderTextBox.TabIndex = 0;
            this.OutputFolderTextBox.Text = "SRP Results";
            // 
            // OutputFolderLabel
            // 
            this.OutputFolderLabel.AutoSize = true;
            this.OutputFolderLabel.Location = new System.Drawing.Point(11, 175);
            this.OutputFolderLabel.Margin = new System.Windows.Forms.Padding(5, 0, 5, 0);
            this.OutputFolderLabel.Name = "OutputFolderLabel";
            this.OutputFolderLabel.Size = new System.Drawing.Size(105, 13);
            this.OutputFolderLabel.TabIndex = 11;
            this.OutputFolderLabel.Text = "Output Folder Name:";
            // 
            // OutputInfoBox
            // 
            this.OutputInfoBox.Controls.Add(this.IntersectionsBox);
            this.OutputInfoBox.Controls.Add(this.OutputFolderTextBox);
            this.OutputInfoBox.Controls.Add(this.OutputFolderLabel);
            this.OutputInfoBox.Location = new System.Drawing.Point(16, 1135);
            this.OutputInfoBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputInfoBox.Name = "OutputInfoBox";
            this.OutputInfoBox.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OutputInfoBox.Size = new System.Drawing.Size(971, 217);
            this.OutputInfoBox.TabIndex = 12;
            this.OutputInfoBox.TabStop = false;
            this.OutputInfoBox.Text = "Data Processing && Output";
            // 
            // IGMNInversionWindow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(192F, 192F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.SystemColors.Window;
            this.ClientSize = new System.Drawing.Size(1003, 1413);
            this.Controls.Add(this.OutputInfoBox);
            this.Controls.Add(this.OutputGroupBox);
            this.Controls.Add(this.RunButton);
            this.Controls.Add(this.InputGroupBox);
            this.Controls.Add(this.TrainingDataInput);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = false;
            this.Name = "IGMNInversionWindow";
            this.Text = "IGMN Rock Physics Inversion";
            this.Load += new System.EventHandler(this.IGMNInversionWindow_Load);
            this.TrainingDataInput.ResumeLayout(false);
            this.TrainingDataInput.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.GridSizeBox)).EndInit();
            this.ResultingSetGroupBox.ResumeLayout(false);
            this.ResultingSetGroupBox.PerformLayout();
            this.ZonesGroupBox.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.ZoneTableView)).EndInit();
            this.WellsGroupBox.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.WellTableView)).EndInit();
            this.InputGroupBox.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.InputCubeTableView)).EndInit();
            this.OutputGroupBox.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.OutputCubeTableView)).EndInit();
            this.IntersectionsBox.ResumeLayout(false);
            this.IntersectionsBox.PerformLayout();
            this.OutputInfoBox.ResumeLayout(false);
            this.OutputInfoBox.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private Slb.Ocean.Petrel.UI.Controls.BasicButton RunButton;
        private System.Windows.Forms.GroupBox TrainingDataInput;
        private System.Windows.Forms.GroupBox ResultingSetGroupBox;
        private System.Windows.Forms.GroupBox ZonesGroupBox;
        private System.Windows.Forms.GroupBox WellsGroupBox;
        private System.Windows.Forms.GroupBox InputGroupBox;
        private Slb.Ocean.Petrel.UI.DropTarget InputCubeDropTarget;
        private System.Windows.Forms.GroupBox OutputGroupBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.DataGridView WellTableView;
        private System.Windows.Forms.TextBox ResultingSetTextBox;
        private System.Windows.Forms.DataGridView ZoneTableView;
        private System.Windows.Forms.DataGridView InputCubeTableView;
        private System.Windows.Forms.DataGridView OutputCubeTableView;
        private System.Windows.Forms.NumericUpDown GridSizeBox;
        private Slb.Ocean.Petrel.UI.DropTarget RandLineDropTarget;
        private System.Windows.Forms.TextBox RandLineTextBox;
        private System.Windows.Forms.TextBox OutputFolderTextBox;
        private System.Windows.Forms.Label OutputFolderLabel;
        private System.Windows.Forms.GroupBox IntersectionsBox;
        private Slb.Ocean.Petrel.UI.Controls.BasicButton ClearIntersectionButton;
        private System.Windows.Forms.GroupBox OutputInfoBox;
    }

}

