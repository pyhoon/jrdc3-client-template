B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'#Macro: Title, Sync Files, ide://run?File=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region
#Region Macros
#Macro: Title, Export, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip
#Macro: Title, GitHub, ide://run?File=%WINDIR%\System32\cmd.exe&Args=/c&Args=github&Args=..\..\
#Macro: Title, JsonLayouts folder, ide://run?File=%WINDIR%\explorer.exe&Args=%PROJECT%\JsonLayouts
#Macro: After Save, Sync Layouts, ide://run?File=%ADDITIONAL%\..\B4X\JsonLayouts.jar&Args=%PROJECT%&Args=%PROJECT_NAME%
#End Region
Sub Class_Globals
	Private xui As XUI
	Private Root As B4XView
	Private lblTitle 	As B4XView
	Private lblBack 	As B4XView
	Private btnNew 		As B4XView
	Private btnEdit 	As B4XView
	Private btnDelete 	As B4XView
	Private lblName 	As B4XView
	Private lblCategory As B4XView
	Private lblCode 	As B4XView
	Private lblPrice 	As B4XView
	Private clvRecord 	As CustomListView
	Private indLoading 	As B4XLoadingIndicator
	Private PrefDialog1 As PreferencesDialog
	Private PrefDialog2 As PreferencesDialog
	Private PrefDialog3 As PreferencesDialog
	Private Viewing 	As String
	Private Title 		As String
	Private Categories 	As Map
	Private CategoryId 	As Int
	Private RED 		As Int = 0xFFDC143C '-2354116 xui.Color_ARGB(255, 220, 20, 60)
	Private GREEN 		As Int = 0xFF32CD32 '-13447886 xui.Color_ARGB(255, 50, 205, 50)
	Private BLUE 		As Int = 0xFF4169E1 '-12490271 xui.Color_ARGB(255, 65, 105, 225)
	Private GRAY 		As Int = 0x80000A28 '-2147481048 xui.Color_ARGB(128, 0, 10, 40)
	Private rdc As RDCManager
	Private Const ServerUrl As String = "http://192.168.50.42:17178/rdc"
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	B4XPages.SetTitle(Me, "JRDC Client")
	rdc.Initialize(ServerUrl)
	Categories.Initialize
	#If B4J
	CallSubDelayed3(Me, "SetScrollPaneBackgroundColor", clvRecord, xui.Color_Transparent)
	#End If
End Sub

Private Sub B4XPage_CloseRequest As ResumableSub
	If xui.IsB4A Then
		'back key in Android
		If PrefDialog1.BackKeyPressed Then Return False
		If PrefDialog2.BackKeyPressed Then Return False
		If PrefDialog3.BackKeyPressed Then Return False
	End If
	If Viewing = "Product" Then
		Viewing = "Category"
		lblTitle.Text = "Category"
		lblBack.Visible = False
		CreateDialog1
		CreateDialog2
		CreateDialog3
		GetCategories
		Return False
	End If
	Return True
End Sub

'Called whenever the page becomes visible. Note that in B4J the Appear and Disappear events are only raised when the page is opened and closed. Not when the focus changes to a different window.
Private Sub B4XPage_Appear
	GetCategories
End Sub

'Called whenever a visible page disappear.
Private Sub B4XPage_Disappear
	
End Sub

Private Sub B4XPage_Resize(Width As Int, Height As Int)
	If PrefDialog1.IsInitialized And PrefDialog1.Dialog.Visible Then PrefDialog1.Dialog.Resize(Width, Height)
	If PrefDialog2.IsInitialized And PrefDialog2.Dialog.Visible Then PrefDialog2.Dialog.Resize(Width, Height)
	If PrefDialog3.IsInitialized And PrefDialog3.Dialog.Visible Then PrefDialog3.Dialog.Resize(Width, Height)
End Sub

'Don't miss the code in the Main module + manifest editor.
Private Sub IME_HeightChanged (NewHeight As Int, OldHeight As Int)
	PrefDialog1.KeyboardHeightChanged(NewHeight)
	PrefDialog2.KeyboardHeightChanged(NewHeight)
	PrefDialog3.KeyboardHeightChanged(NewHeight)
End Sub

#If B4A
Private Sub B4XPage_KeyPress (KeyCode As Int) As Boolean 'ignore
	Select KeyCode
		Case KeyCodes.KEYCODE_BACK
			'code to handle back key
		Case Else
			Return False 'Pass to Android System
	End Select
End Sub
#End If

#If B4J
Private Sub SetScrollPaneBackgroundColor(View As CustomListView, Color As Int)
	Dim SP As JavaObject = View.GetBase.GetView(0)
	Dim V As B4XView = SP
	V.Color = Color
	Dim V As B4XView = SP.RunMethod("lookup", Array(".viewport"))
	V.Color = Color
End Sub
#End If

'Sub CreateRequest As DBRequestManager
'	Dim req As DBRequestManager
'	req.Initialize(Me, rdcLink)
'	Return req
'End Sub

' Do not use cmd in B4i
' https://www.b4x.com/android/forum/threads/jrdc2-with-cmd-not-a-valid-identifier-error.102919/
'Sub CreateCommand (Name As String, Parameters() As Object) As DBCommand
'	Dim command As DBCommand
'	command.Initialize
'	command.Name = "SQL." & Name
'	If Parameters <> Null Then command.Parameters = Parameters
'	Return command
'End Sub

#If B4J
Private Sub lblBack_MouseClicked (EventData As MouseEvent)
#Else
Private Sub lblBack_Click
#End If
	If Viewing = "Product" Then
		Viewing = "Category"
		lblTitle.Text = "Category"
		lblBack.Visible = False
		CreateDialog1
		CreateDialog2
		CreateDialog3
		GetCategories
	End If
End Sub

Private Sub btnReconnect_Click
	If Viewing = "Product" Then
		GetProducts
	Else
		GetCategories
	End If
End Sub

Private Sub btnNew_Click
	If Viewing = "Product" Then
		Dim Item As Map = CreateMap("id": 0, "Category id": CategoryId, "Category Name": GetCategoryName(CategoryId), "Product Code": "", "Product Name": "", "Product Price": "")
		ShowDialog2("Add", Item)
	Else
		Dim Item As Map = CreateMap("id": 0, "Category Name": "")
		ShowDialog1("Add", Item)
	End If
End Sub

Private Sub btnEdit_Click
	Dim Index As Int = clvRecord.GetItemFromView(Sender)
	Dim Item As Map = clvRecord.GetValue(Index)
	If Viewing = "Product" Then
		ShowDialog2("Edit", Item)
	Else
		ShowDialog1("Edit", Item)
	End If
End Sub

Private Sub btnDelete_Click
	Dim Index As Int = clvRecord.GetItemFromView(Sender)
	Dim Item As Map = clvRecord.GetValue(Index)
	ShowDialog3(Item)
End Sub

Private Sub GetCategories
	Try
		indLoading.Show
		clvRecord.Clear
		'Dim req As DBRequestManager = CreateRequest
		'Dim cmd1 As DBCommand = CreateCommand("SELECT_ALL_CATEGORIES", Null)
		'Wait For (req.ExecuteQuery(cmd1, 0, Null)) JobDone (job As HttpJob)
		'If job.Success Then
			'req.HandleJobAsync(job, "req")
			'req.PrintTable(res)
			'Wait For (req) req_Result (res As DBResult)
			'For Each row() As Object In res.Rows
			'	Dim M1 As Map = CreateMap("id": row(0), "Category Name": row(1))
			'	clvRecord.Add(CreateCategoryItems(M1, clvRecord.AsView.Width), M1)
			'	Categories.Put(row(1), row(0))
			'Next
		Wait For (rdc.ExecuteQuery("SELECT_ALL_CATEGORIES", Null)) Complete (Result As RDCResult) 'queries are defined in the server config.properties file
		If Result.Success Then
			Log(Result.Data.ToString(0))
			Categories.Clear
			'If Result.Data.Size > 0 Then
			'	
			'End If
			For Each row() As Object In Result.Data.IterateRows
				'Dim Name As String = Result.Data.GetValue(0, "name")
				'Dim id As Int = Result.Data.GetValue(0, "id")
				'Dim blob() As Byte = Result.Data.GetValue(0, "image")
				'If blob <> Null Then
					'Dim img As B4XBitmap = rdc.BytesToImage(blob)
					'
				'End If
				'Log(Name)
				'Log(id)
				Dim M1 As Map = CreateMap("id": row(0), "Category Name": row(1))
				clvRecord.Add(CreateCategoryItems(M1, clvRecord.AsView.Width), M1)
				Categories.Put(row(1), row(0))
			Next
			Viewing = "Category"
			lblTitle.Text = "Category"
			lblBack.Visible = False
			CreateDialog1
			CreateDialog2
			CreateDialog3
		Else
			xui.MsgboxAsync(Result.ErrorMessage, "Error")
		End If
	Catch
		xui.MsgboxAsync(LastException.Message, "Error")
	End Try
	'job.Release
	indLoading.Hide
End Sub

Private Sub GetProducts
	Try
		indLoading.Show
		clvRecord.Clear
		'Dim req As DBRequestManager = CreateRequest
		'Dim cmd1 As DBCommand = CreateCommand("SELECT_PRODUCT_BY_CATEGORY_ID", Array(CategoryId))
		'Wait For (req.ExecuteQuery(cmd1, 0, Null)) JobDone (job As HttpJob)
		'If job.Success Then
			'req.HandleJobAsync(job, "req")
			'Wait For (req) req_Result (res As DBResult)
			'req.PrintTable(res)
			'For Each row() As Object In res.Rows
			'	Dim M2 As Map = CreateMap("id": row(0), "Category id": row(1), "Category Name": row(2), "Product Code": row(3), "Product Name": row(4), "Product Price": row(5))
			'	clvRecord.Add(CreateProductItems(M2, clvRecord.AsView.Width), M2)
			'Next
		Wait For (rdc.ExecuteQuery("SELECT_PRODUCT_BY_CATEGORY_ID", Array(CategoryId))) Complete (Result As RDCResult) 'queries are defined in the server config.properties file
		If Result.Success Then
			Log(Result.Data.ToString(0))
			'If Result.Data.Size > 0 Then
			'	
			'End If
			For Each row() As Object In Result.Data.IterateRows
				'Dim Name As String = Result.Data.GetValue(0, "name")
				'Dim id As Int = Result.Data.GetValue(0, "id")
				'Dim blob() As Byte = Result.Data.GetValue(0, "image")
				'If blob <> Null Then
					'Dim img As B4XBitmap = rdc.BytesToImage(blob)
					'
				'End If
				'Log(Name)
				'Log(id)
				Dim M2 As Map = CreateMap("id": row(0), "Category id": row(1), "Category Name": row(2), "Product Code": row(3), "Product Name": row(4), "Product Price": row(5))
				clvRecord.Add(CreateProductItems(M2, clvRecord.AsView.Width), M2)
			Next
			Viewing = "Product"
			lblTitle.Text = GetCategoryName(CategoryId)
			lblBack.Visible = True
		Else
			xui.MsgboxAsync(Result.ErrorMessage, "Error")
		End If
	Catch
		xui.MsgboxAsync(LastException.Message, "Error")
	End Try
	'job.Release
	indLoading.Hide
End Sub

Private Sub GetCategoryName (Id As Int) As String
	For Each Key As String In Categories.Keys
		If Id = Categories.Get(Key) Then Return Key
	Next
	Return ""
End Sub

Private Sub clvRecord_ItemClick (Index As Int, Value As Object)
	If Viewing = "Category" Then
		Dim M1 As Map = Value
		CategoryId = M1.Get("id")
		GetProducts
	End If
End Sub

Private Sub CreateCategoryItems (Category As Map, Width As Double) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, Width, 90dip)
	p.LoadLayout("CategoryItem")
	lblName.Text = Category.Get("Category Name")
	Return p
End Sub

Private Sub CreateProductItems (Product As Map, Width As Double) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, Width, 180dip)
	p.LoadLayout("ProductItem")
	lblCategory.Text = Product.Get("Category Name")
	lblCode.Text = Product.Get("Product Code")
	lblName.Text = Product.Get("Product Name")
	lblPrice.Text = NumberFormat2(Product.Get("Product Price"), 1, 2, 2, True)
	Return p
End Sub

Private Sub CreateDialog1
	PrefDialog1.Initialize(Root, "Category", 300dip, 70dip)
	PrefDialog1.Dialog.OverlayColor = GRAY
	PrefDialog1.Dialog.TitleBarHeight = 50dip
	PrefDialog1.LoadFromJson(File.ReadString(File.DirAssets, "category.json"))
	PrefDialog1.SetEventsListener(Me, "PrefDialog1") '<-- must add to handle events.
End Sub

Private Sub CreateDialog2
	Dim Options As List
	Options.Initialize
	For Each Key As String In Categories.Keys
		Options.Add(Key)
	Next
	PrefDialog2.Initialize(Root, "Product", 300dip, 250dip)
	PrefDialog2.Dialog.OverlayColor = GRAY
	PrefDialog2.Dialog.TitleBarHeight = 50dip
	PrefDialog2.LoadFromJson(File.ReadString(File.DirAssets, "product.json"))
	PrefDialog2.SetOptions("Category Name", Options)
	PrefDialog2.SetEventsListener(Me, "PrefDialog2") '<-- must add to handle events.
End Sub

Private Sub CreateDialog3
	PrefDialog3.Initialize(Root, "Delete", 300dip, 70dip)
	PrefDialog3.Theme = PrefDialog3.THEME_LIGHT
	PrefDialog3.Dialog.OverlayColor = GRAY
	PrefDialog3.Dialog.TitleBarHeight = 50dip
	PrefDialog3.Dialog.TitleBarColor = RED
	PrefDialog3.AddSeparator("default")
End Sub

Private Sub ShowDialog1 (Action As String, Category As Map)
	Title = Action & " Category"
	PrefDialog1.Title = Title	
	If Action = "Add" Then
		PrefDialog1.Dialog.TitleBarColor = GREEN
	Else
		PrefDialog1.Dialog.TitleBarColor = BLUE
	End If
	Dim sf As Object = PrefDialog1.ShowDialog(Category, "OK", "CANCEL")
	#if B4A or B4i
	PrefDialog1.Dialog.Base.Top = 100dip ' Make it lower
	#Else
	'Dim sp As ScrollPane = PrefDialog1.CustomListView1.sv
	'sp.SetVScrollVisibility("NEVER")
	Sleep(0)
	PrefDialog1.CustomListView1.sv.Height = PrefDialog1.CustomListView1.sv.ScrollViewInnerPanel.Height + 10dip
	#End If
	' Fix Linux UI (Long Text Button)
	Dim btnCancel As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Cancel)
	btnCancel.Width = btnCancel.Width + 20dip
	btnCancel.Left = btnCancel.Left - 20dip
	btnCancel.TextColor = RED
	Dim btnOk As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Positive)
	btnOk.Left = btnOk.Left - 20dip
	Wait For (sf) Complete (Res As Int)
	If Res = xui.DialogResponse_Positive Then
		'If Action = "Add" Then
		'	Dim cmd1 As DBCommand = CreateCommand("INSERT_NEW_CATEGORY", Array As Object(Category.Get("Category Name")))
		'Else
		'	Dim cmd1 As DBCommand = CreateCommand("UPDATE_CATEGORY_BY_ID", Array As Object(Category.Get("Category Name"), Category.Get("id")))
		'End If
		'Dim job As HttpJob = CreateRequest.ExecuteCommand(cmd1, Null)
		'Wait For (job) JobDone (job As HttpJob)
		'If job.Success Then
		indLoading.Show
		Dim id As Int = Category.Get("id")
		Dim category_name As String = Category.Get("Category Name")
		If Action = "Add" Then
			Wait For (rdc.ExecuteCommand("INSERT_NEW_CATEGORY", Array(category_name))) Complete (Result As RDCResult)
		Else
			Wait For (rdc.ExecuteCommand("UPDATE_CATEGORY_BY_ID", Array(category_name, id))) Complete (Result As RDCResult)
		End If
		If Result.Success Then
			If Action = "Add" Then
				xui.MsgboxAsync("New category created!", Title)
			Else
				xui.MsgboxAsync("Category updated!", Title)
			End If
			GetCategories
		Else
			LogColor(Result.ErrorMessage, RED)
			xui.MsgboxAsync(Result.ErrorMessage, Title)
		End If
		'job.Release
		indLoading.Hide
	End If
End Sub

Private Sub ShowDialog2 (Action As String, Product As Map)
	Title = Action & " Product"
	PrefDialog2.Title = Title
	If Action = "Add" Then
		PrefDialog2.Dialog.TitleBarColor = GREEN
	Else
		PrefDialog2.Dialog.TitleBarColor = BLUE
	End If	
	Dim sf As Object = PrefDialog2.ShowDialog(Product, "OK", "CANCEL")
	Sleep(0)
	PrefDialog2.CustomListView1.sv.Height = PrefDialog2.CustomListView1.sv.ScrollViewInnerPanel.Height + 10dip
	Wait For (sf) Complete (Res As Int)
	If Res = xui.DialogResponse_Positive Then
		indLoading.Show
		Dim category_id As Int = Categories.Get(Product.Get("Category Name"))
		Dim product_code As String = Product.Get("Product Code")
		Dim product_name As String = Product.Get("Product Name")
		Dim product_price As Double = Product.Get("Product Price").As(String).Replace(",", "")
		Dim id As Int = Product.Get("id")
		'If Action = "Add" Then
		'	Dim cmd1 As DBCommand = CreateCommand("INSERT_NEW_PRODUCT", Array(category_id, product_code, product_name, product_price))
		'Else
		'	Dim cmd1 As DBCommand = CreateCommand("UPDATE_PRODUCT_BY_ID", Array(category_id, product_code, product_name, product_price, product_id))
		'End If
		'Dim job As HttpJob = CreateRequest.ExecuteCommand(cmd1, Null)
		'Wait For (job) JobDone (job As HttpJob)
		'If job.Success Then
		If Action = "Add" Then
			Wait For (rdc.ExecuteCommand("INSERT_NEW_PRODUCT", Array(category_id, product_code, product_name, product_price))) Complete (Result As RDCResult)
		Else
			Wait For (rdc.ExecuteCommand("UPDATE_PRODUCT_BY_ID", Array(category_id, product_code, product_name, product_price, id))) Complete (Result As RDCResult)
		End If
		If Result.Success Then		
			If Action = "Add" Then
				xui.MsgboxAsync("New product created!", Title)
			Else
				xui.MsgboxAsync("Product updated!", Title)
			End If
			CategoryId = category_id
			GetProducts
		Else
			xui.MsgboxAsync(Result.ErrorMessage, Title)
		End If
		'job.Release
		indLoading.Hide
	End If
End Sub

Private Sub PrefDialog1_BeforeDialogDisplayed (Template As Object)
	Try
		' Fix Linux UI (Long Text Button)
		Dim btnCancel As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 20dip
		btnCancel.TextColor = RED
		Dim btnOk As B4XView = PrefDialog1.Dialog.GetButton(xui.DialogResponse_Positive)
		If btnOk.IsInitialized Then
			btnOk.Width = btnOk.Width + 20dip
			btnOk.Left = btnCancel.Left - btnOk.Width
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub PrefDialog2_BeforeDialogDisplayed (Template As Object)
	Try
		' Fix Linux UI (Long Text Button)
		Dim btnCancel As B4XView = PrefDialog2.Dialog.GetButton(xui.DialogResponse_Cancel)
		btnCancel.Width = btnCancel.Width + 20dip
		btnCancel.Left = btnCancel.Left - 20dip
		btnCancel.TextColor = RED
		Dim btnOk As B4XView = PrefDialog2.Dialog.GetButton(xui.DialogResponse_Positive)
		If btnOk.IsInitialized Then
			btnOk.Width = btnOk.Width + 20dip
			btnOk.Left = btnCancel.Left - btnOk.Width
		End If
	Catch
		Log(LastException)
	End Try
End Sub

Private Sub ShowDialog3 (Item As Map)
	Title = "Delete " & Viewing
	PrefDialog3.Title = Title
	Dim sf As Object = PrefDialog3.ShowDialog(Item, "OK", "CANCEL")
	#if B4A or B4i
	PrefDialog3.Dialog.Base.Top = 100dip ' Make it lower
	#Else
	' Fix Linux UI (Long Text Button)
	'Dim sp As ScrollPane = PrefDialog3.CustomListView1.sv
	'sp.SetVScrollVisibility("NEVER")
	Sleep(0)
	PrefDialog3.CustomListView1.sv.Height = PrefDialog3.CustomListView1.sv.ScrollViewInnerPanel.Height + 10dip
	#End If
	Dim btnCancel As B4XView = PrefDialog3.Dialog.GetButton(xui.DialogResponse_Cancel)
	btnCancel.Width = btnCancel.Width + 20dip
	btnCancel.Left = btnCancel.Left - 20dip
	btnCancel.TextColor = RED
	Dim btnOk As B4XView = PrefDialog3.Dialog.GetButton(xui.DialogResponse_Positive)
	btnOk.Left = btnOk.Left - 20dip
	If Viewing = "Product" Then
		PrefDialog3.CustomListView1.GetPanel(0).GetView(0).Text = Item.Get("Product Name")
	Else
		PrefDialog3.CustomListView1.GetPanel(0).GetView(0).Text = Item.Get("Category Name")
	End If
	#If B4i
	PrefDialog3.CustomListView1.GetPanel(0).GetView(0).TextSize = 16 ' Text too small in ios
	#Else
	PrefDialog3.CustomListView1.GetPanel(0).GetView(0).TextSize = 15 ' 14
	#End If
	PrefDialog3.CustomListView1.GetPanel(0).GetView(0).Color = xui.Color_Transparent
	PrefDialog3.CustomListView1.sv.ScrollViewInnerPanel.Color = xui.Color_Transparent
	Wait For (sf) Complete (Res As Int)
	If Res = xui.DialogResponse_Positive Then
		indLoading.Show
		Dim id As Int = Item.Get("id")
		'If Viewing = "Product" Then
		'	Dim cmd1 As DBCommand = CreateCommand("DELETE_PRODUCT_BY_ID", Array(Item.Get("id")))
		'Else
		'	Dim cmd1 As DBCommand = CreateCommand("DELETE_CATEGORY_BY_ID", Array(Item.Get("id")))
		'End If
		'Dim job As HttpJob = CreateRequest.ExecuteCommand(cmd1, Null)
		'Wait For (job) JobDone (job As HttpJob)
		'If job.Success Then
		If Viewing = "Product" Then
			Wait For (rdc.ExecuteCommand("DELETE_PRODUCT_BY_ID", Array(id))) Complete (Result As RDCResult)
		Else
			Wait For (rdc.ExecuteCommand("DELETE_CATEGORY_BY_ID", Array(id))) Complete (Result As RDCResult)
		End If
		If Result.Success Then
			xui.MsgboxAsync(Viewing & " deleted!", Title)
		Else
			xui.MsgboxAsync(Result.ErrorMessage, Title)
		End If
		'job.Release
		indLoading.Hide
		btnReconnect_Click
	End If
End Sub



Public Sub ConvertColorToHexAndARGB (Color As Int) As String
	Private res() As Int = GetARGB(Color)
	'Return $"${ArrayToHex(res)} ${ArrayToString(res)}"$
	Return $"0x${Bit.ToHexString(Color).ToUpperCase} '${Color} ${ArrayToString(res)}"$
End Sub

'https://www.b4x.com/android/forum/threads/get-the-rgb-color-from-getpixel.56760/#post-357302
Public Sub GetARGB (Color As Int) As Int()
	Private res(4) As Int
	res(0) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff000000), 24)
	res(1) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff0000), 16)
	res(2) = Bit.UnsignedShiftRight(Bit.And(Color, 0xff00), 8)
	res(3) = Bit.And(Color, 0xff)
	Return res
End Sub

Public Sub ArrayToString (res() As Int) As String
	Return $"xui.Color_ARGB(${res(0)}, ${res(1)}, ${res(2)}, ${res(3)})"$
End Sub

Public Sub ArrayToHex (res() As Int) As String
	Log(Bit.ToHexString(res(0)))
	Log(Bit.ToHexString(res(1)))
	Log(Bit.ToHexString(res(2)))
	Log(Bit.ToHexString(res(3)))
	Return $"0x${Bit.ToHexString(res(0))}${Bit.ToHexString(res(1))}${Bit.ToHexString(res(2))}${Bit.ToHexString(res(3))}"$
End Sub