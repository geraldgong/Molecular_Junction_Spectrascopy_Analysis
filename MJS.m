function MJS
	clear all; close all;

	f = figure();
	f.Name = 'MJS';
	set(f,'defaultAxesColorOrder',[[0 0 1]; [1 0 0]])
	set(f, 'Resize', 'off')
	set(f, 'MenuBar', 'None')
	set(f, 'Toolbar', 'figure')
	b1 = findall(f,'ToolTipString','Open File');
	set(b1, 'Visible', 'off')
	b2 = findall(f,'ToolTipString','New Figure');
	set(b2, 'Visible', 'off')
	b3 = findall(f,'ToolTipString','Rotate 3D');
	set(b3, 'Visible', 'off')

	% split the figure to 2 panels
	vbox = uiextras.VBox('Parent', f);
	panel{1} = uiextras.BoxPanel( 'Title',[], 'TitleColor', [.95 .95 .95], ...
		'FontSize', .5,'FontWeight', 'bold',...
	     'Parent', vbox);
	panel{2} = uiextras.BoxPanel( 'Title', 'Peak-fitting Panel',...
		 'TitleColor', 'k', 'FontSize', 11, 'FontAngle', 'italic', ...
		 'Parent', vbox);
	set(vbox, 'Sizes', [500 25])
	set(panel{2}, 'Minimized', true)


	% first panel contains 3 tabs
	p = uiextras.TabPanel('Parent', panel{1}, 'Padding', 5 );

	tab1 = uibuttongroup('Parent', p);
	tab2 = uibuttongroup('Parent', p);
	tab3 = uibuttongroup('Parent', p);
	% set(tab1, 'BackgroundColor', [0 0 0])

	p.TabNames = {'Spectra', 'I-V/ I-d', 'Peak-fitting'};
	p.TabSize = 100;
	p.FontSize = 11;
	p.FontAngle = 'italic';
	p.SelectedChild = 3;

	pf = uibuttongroup('Parent', panel{2});

	pos = get(f, 'Position');
	set(f, 'Position', [100, 100, 900, sum(vbox.Sizes)] );
	set(panel{2}, 'MinimizeFcn', {@nMinimize, 2});

%% Spectra tab1 ----------------------------------------------------------------------------------------------------

	%database 
	sp_p01 = uipanel(tab1, 'Title', 'Database Path', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'FontWeight', 'bold','Position', [.02 .87 .35 .10]);
	s_tpath = uicontrol(sp_p01, 'Style', 'edit', 'String', [], 'FontName', 'Helvetica', 'FontSize', 10, ...
		 'Units', 'normalized','Position', [.04 .1 .7 .8]);
	bpath = uicontrol(sp_p01,'Style', 'pushbutton', 'String', 'PATH', 'FontName', 'Helvetica', 'FontSize', 9, ...
		 'Units', 'normalized', 'Position', [.77, .1, .21, .8], 'Callback', @sp_path_Callback);

  	% choose date
	sp_p02 = uipanel(tab1, 'Title', 'Choose Date', 'FontName', 'Helvetica', 'FontSize', 10,...
		'FontWeight', 'bold','Position', [.02 .75 .25 .10]);
	tdate = uicontrol(sp_p02, 'Style', 'edit', 'String', [], ... 'FontName', 'Helvetica', 'FontSize', 10, ...
		 'Units', 'normalized', 'Position', [.05 .1  .6 .8]);
	bdate = uicontrol(sp_p02,'Style', 'pushbutton', 'String', 'DATE',  'FontName', 'Helvetica', 'FontSize', 9, ...
		 'Units', 'normalized', 'Position', [.69 .1 .28 .8], 'Callback', @sp_date_Callback);

	% counts1 panel
	sp_p03 = uipanel(tab1, 'Title', 'Counts', 'FontName', 'Helvetica', 'FontSize', 10,...
		'FontWeight', 'bold','Position', [.28 .75 .09 .10]);
	tcount1 = uicontrol(sp_p03, 'Style', 'edit', 'String', 0, 'FontName', 'Helvetica', 'FontSize', 10,...
		'Units', 'normalized', 'Position', [.1 .1 .8 .8]);

	% load panel
	sp_p04 = uipanel(tab1, 'Title', 'Select Data', 'FontName', 'Helvetica', 'FontSize', 10,...
		'FontWeight', 'bold', 'Position', [.12 .63 .15 .10]);
	bload = uicontrol(sp_p04,'Style', 'pushbutton', 'String', 'LOAD', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 9,...
		'Position', [.25, .1, .5, .8], 'Callback', @sp_load_Callback);

	% counts2 panel
	sp_p05 = uipanel(tab1, 'Title', 'Counts','FontName', 'Helvetica', 'FontSize', 10, ...
		'FontWeight', 'bold', 'Position', [.28 .63 .09 .10]);
	sp_tnum = uicontrol(sp_p05, 'Style', 'edit', 'String', 0, 'FontName', 'Helvetica', 'FontSize', 10,...
		'Units', 'normalized', 'Position', [.1 .1 .8 .8]);

	% refresh panel
	sp_pr = uipanel(tab1, 'Title', 'Refresh', 'FontName', 'Helvetica', 'FontSize', 10,...
		'FontWeight', 'bold','Position', [.02 .63 .09 .10]);

 	[x_f map_f alpa] = imread('refresh_icon.jpg');
 	% tcount1 = uicontrol(sp_pr, 'Style', 'pushbutton', 'CData', x_f, 'FontName', 'Helvetica', 'FontSize', 10,...
		% 'Units', 'normalized', 'Position', [.3 .1 .4 .8]);
	sp_rf = uicontrol(sp_pr, 'Style', 'pushbutton', 'CData', x_f, 'FontName', 'Helvetica', 'FontSize', 10,...
		'Units', 'normalized', 'Position', [.35 .1 .3 .8], 'Callback', @refresh_Callback);

	
	% List panel
	sp_p06 = uipanel(tab1, 'Title', 'Data List', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'FontWeight', 'bold','Position', [.02 .03 .35 .58]);
	spl_file = uicontrol(sp_p06,'Style','listbox', 'String',{ }, 'Units', 'normalized',...
		'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.04 .03 .92 .95], 'Value', 1, 'Callback', @sp_list_Callback);

	% Spectrum panel
	sp_p07 = uipanel(tab1, 'Title', 'Spectrum', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.39 .2 .59 .77]);
	sp_ax = axes(sp_p07, 'Position', [.12 .15 .76 .8]);
	sp_initial_Callback

	% Range panel
	sp_p08 = uipanel(tab1, 'Title', 'Range', 'FontWeight', 'bold', 'FontName', 'Helvetica', ...
		'FontSize', 10,'Position', [.39 .03 .19 .15]);
	sp_txmin = uicontrol(sp_p08, 'Style', 'edit', 'String', 800, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10,'Position', [.08, .1, .38, .45], 'Callback', @sp_list_Callback);
	spl_xmin  = uicontrol(sp_p08, 'Style','text','String','xmin', 'Units', 'normalized', ...
          'FontName', 'Helvetica', 'FontSize', 9, 'Position',[.12, .55, .3, .3]);
	sp_txmax = uicontrol(sp_p08, 'Style', 'edit', 'String', 2000, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10,'Position', [.54, .1, .38, .45], 'Callback', @sp_list_Callback);
	spl_xmax  = uicontrol(sp_p08, 'Style','text','String','xmax', 'Units', 'normalized', ...
           'FontName', 'Helvetica', 'FontSize', 9, 'Position',[.58, .55, .3, .3]);

	% Save panel
	sp_p09 = uipanel(tab1, 'Title', 'Save Data', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.6 .03 .38 .15]);
	sp_psave = uicontrol(sp_p09,'Style', 'pushbutton', 'String', '>','FontName', 'Helvetica', 'FontSize', 10, ...
		'Units', 'normalized', 	'Position', [.02, .1, .08, .45], 'Callback', @sp_savepath_Callback);
	sp_tsave = uicontrol(sp_p09, 'Style', 'edit', 'String', [],  'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.11, .1, .7, .45]);
	sp_bsave = uicontrol(sp_p09,'Style', 'pushbutton', 'String', 'SAVE', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.82, .1, .16, .45], 'Callback', @sp_save_Callback);
	spl_save  = uicontrol(sp_p09, 'Style','text','String','Save to', 'Units', 'normalized', ...
           'FontName', 'Helvetica', 'FontSize', 9, 'Position',[0.0, .55, .2, .3]);



%% I-V/I-d tab2 ----------------------------------------------------------------------------------------------------

	% load panel
	p0 = uipanel(tab2, 'Title', 'Import', 'FontName', 'Helvetica', 'FontSize', 10, ...
		 'FontWeight', 'bold', 'Position', [.02 .87 .1 .10]);
	bload = uicontrol(p0,'Style', 'pushbutton', 'String', 'LOAD', 'Units', 'normalized',...
		'FontName', 'Helvetica', 'FontSize', 9, ...
		'Position', [.2, .1, .6, .8], 'Callback', @loadbutton_Callback);

	% counts panel
	p1 = uipanel(tab2, 'Title', 'Counts','FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.13 .87 .15 .10]);
	cnum = uicontrol(p1, 'Style', 'edit', 'String', 0, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.05, .1, .4, .8]); 
	lnum = uicontrol(p1, 'Style', 'text', 'String', '/', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'bold' ,'Position', [.45, .15, .1, .8]); 
	tnum = uicontrol(p1, 'Style', 'edit', 'String', 0, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.55, .1, .4, .8]);

	
	% List panel
	p2 = uipanel(tab2, 'Title', 'Data List', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.02 .03 .26 .82]);
	l_file = uicontrol(p2,'Style','listbox', 'String',{ }, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.04 .03 .92 .95], 'Value', 1, 'Callback', @listbox_Callback);

	% Curve panel
	p3 = uipanel(tab2, 'Title', 'Curves', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ... 
		'Position', [.30 .2 .68 .77]);
	ax = axes(p3, 'Position', [.1 .15 .79 .78]);
	idv_initial_Callback

	% Range panel
	p4 = uipanel(tab2, 'Title', 'Range', 'FontWeight', 'bold','FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.30 .03 .28 .15]);
	txmin = uicontrol(p4, 'Style', 'edit', 'String', -1.5, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.04, .1, .2, .45], ...
		'Callback', @range_Callback);
	l_xmin  = uicontrol(p4, 'Style','text','String','xmin', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.04, .55, .2, .3]);
	txmax = uicontrol(p4, 'Style', 'edit', 'String', 1.5, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.28, .1, .2, .45], ...
		'Callback', @range_Callback);
	l_xmax  = uicontrol(p4, 'Style','text','String','xmax', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.28, .55, .2, .3]);
	tymin = uicontrol(p4, 'Style', 'edit', 'String', -0.5, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.52, .1, .2, .45], ...
		'Callback', @listbox_Callback);
	l_ymin = uicontrol(p4, 'Style','text','String','ymin', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.52, .55, .2, .3]);
 	tymax = uicontrol(p4, 'Style', 'edit', 'String', 0.5, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.76, .1, .2, .45], ...
		'Callback', @listbox_Callback);
 	l_ymax  = uicontrol(p4, 'Style','text','String','ymax', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.76, .55, .2, .3]);


	% Save panel
	% [x_f map_f] = imread('open-icon.png');
	% I_f = ind2rgb(x_f, map_f);
	p5 = uipanel(tab2, 'Title', 'Save Data', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.6 .03 .38 .15]);
	psave = uicontrol(p5,'Style', 'pushbutton', 'String', '>', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.02, .1, .08, .45], ...
		'Callback', @path_Callback);
	tsave = uicontrol(p5, 'Style', 'edit', 'String', [],  'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.11, .1, .7, .45]);
	bsave = uicontrol(p5,'Style', 'pushbutton', 'String', 'SAVE', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.82, .1, .16, .45], ...
		'Callback', @save_Callback);
	l_save  = uicontrol(p5, 'Style','text','String','Save to', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position',[.0, .55, .2, .3]);


	%% Peak-fitting tab3 ----------------------------------------------------------------------------------------------------

	% load panel
	pf_p0 = uipanel(tab3, 'Title', 'Import', 'FontName', 'Helvetica', 'FontSize', 10, ...
		 'FontWeight', 'bold', 'Position', [.02 .87 .10 .10]);
	pf_bload = uicontrol(pf_p0,'Style', 'pushbutton', 'String', 'LOAD', 'Units', 'normalized',...
		'FontName', 'Helvetica', 'FontSize', 9, ...
		'Position', [.15, .1, .7, .8], 'Callback', @pf_load_Callback);

	% counts panel
	pf_p1 = uipanel(tab3, 'Title', 'Counts','FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.14 .87 .18 .10]);
	pf_cnum = uicontrol(pf_p1, 'Style', 'edit', 'String', 0, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.1, .1, .35, .8]); 
	pf_lnum = uicontrol(pf_p1, 'Style', 'text', 'String', '/', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'bold' ,'Position', [.45, .15, .1, .8]); 
	pf_tnum = uicontrol(pf_p1, 'Style', 'edit', 'String', 0, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.55, .1, .35, .8]);

	% list panel
	pf_p2 = uipanel(tab3, 'Title', 'Data List', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.02 .32 .3 .53]);
	pfl_file = uicontrol(pf_p2,'Style','listbox', 'String', { }, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.04 .03 .92 .95], 'Value', 1, 'Callback', @pf_list_Callback);

	% range panel
	pf_p3 = uipanel(tab3, 'Title', 'Spectrum Range', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.02 .2 .3 .1]);
	pf_txmin = uicontrol(pf_p3, 'Style', 'edit', 'String', 800, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.1, .1, .25, .8], 'Callback', @pf_list_Callback);

	[x_r map_r alpha] = imread('arrow.png');
 	axes(pf_p3, 'Position', [.4, .1, .2, .8], 'Color', 'none');
 	pf_fig= imshow(x_r);
 	set(pf_fig, 'AlphaData', alpha);

    pf_txmax = uicontrol(pf_p3, 'Style', 'edit', 'String', 2000, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.65, .1, .25, .8], 'Callback', @pf_list_Callback);

    % parameters
	pf_p4 = uipanel(tab3, 'Title', 'Fitting Parameters', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.02 .03 .56 .15]);
	pf_sxmin = uicontrol(pf_p4, 'Style', 'edit', 'String', 1500, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.05, .1, .14, .45], 'Callback', @pf_list_Callback);
	pf_lsxmin  = uicontrol(pf_p4, 'Style','text','String','Range L.', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.05, .55, .15, .3]);
	pf_sxmax = uicontrol(pf_p4, 'Style', 'edit', 'String', 1700, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.24, .1, .14, .45], 'Callback', @pf_list_Callback);
	pf_lsxmax  = uicontrol(pf_p4, 'Style','text','String','Range R.', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.24, .55, .15, .3]);
	pf_pinit = uicontrol(pf_p4, 'Style', 'edit', 'String', 1600, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.43, .1, .14, .45], 'Callback', @pf_list_Callback);
	pf_lpinit  = uicontrol(pf_p4, 'Style','text','String','Init. Peak C.', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9,  'Position', [.43, .55, .15, .3]);
	pf_winit = uicontrol(pf_p4, 'Style', 'edit', 'String', 20, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.62, .1, .14, .45], 'Callback', @pf_list_Callback);
	pf_lwinit  = uicontrol(pf_p4, 'Style','text','String','Init. FWHM', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.61, .55, .16, .3]);
	pf_iinit = uicontrol(pf_p4, 'Style', 'edit', 'String', 40, 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.81, .1, .14, .45], 'Callback', @pf_list_Callback);
	pf_liinit  = uicontrol(pf_p4, 'Style','text','String','Init. Inty', 'Units', 'normalized', ...
        'FontName', 'Helvetica', 'FontSize', 9,  'Position', [.81, .55, .15, .3]);

	% Spectrum panel
	pf_p7 = uipanel(tab3, 'Title', 'Peak-fitting', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.34 .2 .64 .77]);

	[x_res map_res alpa] = imread('chat_icon.png');
 	axes(pf_p7, 'Position', [.09, .87, .12, .12], 'Color', 'none');
 	pf_res= imshow(x_res);
 	set(pf_res, 'AlphaData', alpa);
	pf_para1 = uicontrol(pf_p7, 'Style', 'edit', 'String', [], 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.21, .87, .12, .07]);
	pfl_para1  = uicontrol(pf_p7, 'Style','text','String','Peak C.', 'Units', 'normalized', ...
    'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.21, .94, .12, .05]);
	pf_para2 = uicontrol(pf_p7, 'Style', 'edit', 'String', [], 'Units', 'normalized', ...
	'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.37, .87, .12, .07]);
	pfl_para2  = uicontrol(pf_p7, 'Style','text','String','FWHM', 'Units', 'normalized', ...
    'FontName', 'Helvetica', 'FontSize', 9,'Position', [.37, .94, .1, .05]);
	pf_para3 = uicontrol(pf_p7, 'Style', 'edit', 'String', [], 'Units', 'normalized', ...
	'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.53, .87, .12, .07]);
	pfl_para3  = uicontrol(pf_p7, 'Style','text','String','Intensity', 'Units', 'normalized', ...
    'FontName', 'Helvetica', 'FontSize', 9,'Position', [.53, .94, .12, .05]);
	pf_ax = axes(pf_p7, 'Position', [.12 .15 .84 .7]);
	sp_initial_Callback
	
	% Save panel 1
	pf_p9 = uipanel(tab3, 'Title', 'Save Data', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.6 .03 .38 .15]);
	pf_psave = uicontrol(pf_p9,'Style', 'pushbutton', 'String', '>','FontName', 'Helvetica', 'FontSize', 10, ...
		'Units', 'normalized', 	'Position', [.02, .1, .08, .45], 'Callback', @pf_savepath_Callback);
	pf_tsave = uicontrol(pf_p9, 'Style', 'edit', 'String', [],  'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.11, .1, .7, .45]);
	pf_bsave = uicontrol(pf_p9,'Style', 'pushbutton', 'String', 'SAVE', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.82, .1, .16, .45], 'Callback', @pf_save_Callback);
	pfl_save  = uicontrol(pf_p9, 'Style','text','String','Save to', 'Units', 'normalized', ...
           'FontName', 'Helvetica', 'FontSize', 9, 'Position',[0.0, .55, .2, .3]);

%%  peak-fitting Panel
	
	% tendency panel
	pf_p10 = uipanel(pf, 'Title', 'Tendency', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.02 .03 .56 .95]);
	pfp_ax = axes(pf_p10, 'Position', [.15 .15 .73 .8]);
	pfp_initial_Callback

	% table initilizazion
	d = pf_table_initial; 
	pf_p11 = uipanel(pf, 'Title', 'Results Check', 'FontWeight', 'bold', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.6 .24 .38 .74]);
	pfp_tabel = uitable('Parent', pf_p11, 'Data', d, ...
		'Units', 'normalized', 'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.05 .05 .9 .9]);
	pfp_tabel.ColumnName = {'Peak C.', 'Intensity', 'Kick-out'};
	pfp_tabel.ColumnEditable = true;
	pfp_tabel.CellEditCallback = @pf_list_Callback;

	% Save panel 2
	pf_p12 = uipanel(pf, 'Title', 'Save Data', 'FontWeight', 'bold', 'FontName', 'Helvetica', 'FontSize', 10, ...
		'Position', [.6 .03 .38 .18]);
	pfp_psave = uicontrol(pf_p12,'Style', 'pushbutton', 'String', '>','FontName', 'Helvetica', 'FontSize', 10, ...
		'Units', 'normalized', 	'Position', [.02, .1, .08, .45], 'Callback', @pfp_savepath_Callback);
	pfp_tsave = uicontrol(pf_p12, 'Style', 'edit', 'String', [],  'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 10, 'Position', [.11, .1, .7, .45]);
	pfp_bsave = uicontrol(pf_p12,'Style', 'pushbutton', 'String', 'SAVE', 'Units', 'normalized', ...
		'FontName', 'Helvetica', 'FontSize', 9, 'Position', [.82, .1, .16, .45], 'Callback', @pfp_save_Callback);
	pfp_lsave  = uicontrol(pf_p12, 'Style','text','String','Save to', 'Units', 'normalized', ...
           'FontName', 'Helvetica', 'FontSize', 9, 'Position',[0.0, .55, .2, .3]);

%% Public functions ----------------------------------------------------------------------------------------------------

	function nMinimize( eventSource, eventData, whichpanel )
        % A panel has been maximized/minimized
        s = get(vbox, 'Sizes' );
        pos = get(f, 'Position' );
        panel{whichpanel}.IsMinimized = ~panel{whichpanel}.IsMinimized;
        if panel{whichpanel}.IsMinimized
            s(whichpanel) = 25;
        else
            s(whichpanel) = 400;
        end 
        set(vbox, 'Sizes', s );
        
        % Resize the figure, keeping the top stationary
        delta_height = pos(1,4) - sum(vbox.Sizes);
        set(f, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % Minimize 


	function sp_initial_Callback(hObject, eventdata)
		box on
		xlim([800 2000])
		ylim([0 200])
	    legend off;
	    grid on;
		xlabel('Raman Shift (1/cm)')
		ylabel('Intensity (cps)')
		set(gca,'XMinorTick','on','YMinorTick','on')

	end

%% Spectra functions ----------------------------------------------------------------------------------------------------

	
	function sp_path_Callback(hObject, eventdata)

		
		set(tcount1, 'String', 0);
		set(sp_tnum, 'String', 0);
		set(spl_file, 'String', []);
		set(spl_file, 'Value', 1);
		axes(sp_ax)
		cla(sp_ax,'reset');
		sp_initial_Callback

		files = [];
  		path_temp = uigetdir();

  		if (path_temp ~= 0)
    		datapath = path_temp;
  		else
   	 		return;
  		end
  		h = showinfowindow({'Data Loading ... ' 'Please Wait'}); % pop-up window
  		set(s_tpath,'String', datapath);

  		path(path, datapath);

  		files = dir(datapath);
  		data = files;
  		data([data.isdir]) = []; % remove directories

  		handles = guidata(hObject);
  		handles.data = data;
  		% get the modified date of the files
  		dateunique = zeros(1,length(data));
		for i = 1:length(data);
		  dateunique(i) = data(i).datenum;
		end
		dateunique = unique(fix(dateunique));
		handles.dunique = dateunique;
		
		close(h);
		guidata(hObject, handles);

	end

	function sp_date_Callback(hObject, eventdata)

		set(tcount1, 'String', 0);
		set(sp_tnum, 'String', 0);
		set(spl_file, 'String', []);
		set(spl_file, 'Value', 1);
		axes(sp_ax)
		cla(sp_ax,'reset');
		sp_initial_Callback

		datapath = get(s_tpath,'String');

		if (isempty(datapath))
	    	msgbox('Please assign a valid database path!','Error','error');
	    	return;
  		end

  		handles = guidata(hObject);
		data = handles.data;
		dateunique = handles.dunique;

  		uicalendar('Weekend', [0 0 0 0 0 0 0], ...  
	    'SelectionType', 1, ...  
	    'DestinationUI', {tdate,'String'}, ...
	    'WindowStyle', 'Modal', ...
	    'Holiday', dateunique);
	    waitfor(tdate,'String');

	    selected = get(tdate,'String');
		select_date = datetime(selected);
		select_date.Format = 'yy.MM.dd';
		select_date = char(select_date);
		name = {data.name};
		expression = strcat('SP[_\s]', select_date);
		idx = regexp(name, expression);
		idx = ~cellfun('isempty',idx);
		filename = name(idx);
		filename = fliplr(filename);
		number = length(filename);
		handles.filenum = number;
		message = {'NO DATA FOUND ...'};
		if (number ~= 0)
			set(spl_file, 'String', filename);
			set(tcount1, 'String', number);
		else
			set(spl_file, 'String', message);
			set(tcount1, 'String', number);
			return;
		end
		guidata(hObject, handles);

	end

	function refresh_Callback(hObject, eventdata)

		set(tcount1, 'String', 0);
		set(sp_tnum, 'String', 0);
		set(spl_file, 'String', []);
		axes(sp_ax)
		cla(sp_ax,'reset');
		sp_initial_Callback

		datapath = get(s_tpath,'String');
		selected = get(tdate,'String');

		if (isempty(datapath) | isempty(selected))
			return;
		end
		
		handles = guidata(hObject);
		files = dir(datapath);
  		data = files;
  		data([data.isdir]) = [];
  		handles.data = data;

		select_date = datetime(selected);
		select_date.Format = 'yy.MM.dd';
		select_date = char(select_date);
		name = {data.name};
		expression = strcat('SP[_\s]', select_date);
		idx = regexp(name, expression);
		idx = ~cellfun('isempty',idx);
		filename = name(idx);
		filename = fliplr(filename);
		number = length(filename);
		
		message = {'NO DATA FOUND ...'};
		if (number ~= 0)
			pause(1)
			set(spl_file, 'String', filename, 'Value', 1);
			set(tcount1, 'String', number);
		else
			pause(1)
			set(spl_file, 'String', message, 'Value', 1);
			set(tcount1, 'String', number);
			return;
		end
		drawnow();
		guidata(hObject, handles);

	end

	function sp_load_Callback(hObject, eventdata)

		set(s_tpath, 'String', []);
		set(tdate, 'String', [])
		set(tcount1, 'String', 0);
		set(sp_tnum, 'String', 0);
		set(spl_file, 'String', []);
		set(spl_file, 'Value', 1);
		axes(sp_ax)
		cla(sp_ax,'reset');
		sp_initial_Callback

		[files, pathname, filterindex] = uigetfile('.dat', 'MultiSelect','on');
		if(pathname == 0)
    		return;
  		end
		path(path, pathname);
		if(iscell(files) == 0)
			files = {files};
		end

		filecount = length(files);
		set(sp_tnum, 'String', filecount);
		set(spl_file, 'String', files);

	end

	function sp_list_Callback(hObject, eventdata)

		selected = get(spl_file, 'Value');
    	data_str = get(spl_file, 'String');

    	if (isempty(data_str))
      		return;
    	end
    	
    	xmin = str2num(get(sp_txmin, 'String'));
		xmax = str2num(get(sp_txmax, 'String'));
		if (xmin >= xmax)
			return;
		end

		dataname = data_str{selected};

		if (strcmp(dataname, '0')| strcmp(dataname, 'NO DATA FOUND ...'))
    		return;
    	end

		idx_type = regexp(dataname, 'SP');
		if(isempty(idx_type))
			msgbox('Please load spectrum data only !','Error','error');
			return;
		end

    	data = load(dataname);
    	X = data(:,1);
    	Y = data(:,2);
    	axes(sp_ax)
    	[BL, Inty] = RCF(data, xmin, xmax);
    	yyaxis left
    	plot(sp_ax, X, Y, 'LineWidth', 1.2);
    	hold on
    	plot(sp_ax,	X, BL, 'Color', [0.38 0.38 0.38], 'LineWidth', 1.2);
    	hold off
    	xlim([xmin xmax])
    	ylim auto
    	ylabel('Raw (cps)')
    	set(gca,'XMinorTick','on','YMinorTick','on')
    	yyaxis right
    	plot(sp_ax, X, Inty, 'LineWidth', 1.2)
    	idx1 = find(X>xmin, 1);
    	idx2 = find(X<xmax,1, 'last');
    	yrange = Inty(idx1:idx2);
    	xlim([xmin xmax])
    	ylim([-2 2*max(yrange)]);
    	ylabel('Baseline Substracted (cps)')
    	set(gca,'XMinorTick','on','YMinorTick','on')

    	handles = guidata(hObject);
    	data_bc = [X Inty];
    	handles.data_corrected = data_bc;
    	guidata(hObject, handles);
 
	end

	function sp_savepath_Callback(hObject, eventdata)

		folder_name = uigetdir;
		if (folder_name == 0)
			return;
		end
		set(sp_tsave, 'String', folder_name);
		
	end

	function sp_save_Callback(hObject, eventdata)

		pathname = get(sp_tsave, 'String');
		if (isempty(pathname ==1) | exist(pathname, 'dir') == 0)
			msgbox('Please assign a valid folder!','Error','error');
			return;
		end
		selected = get(spl_file, 'Value');
    	data_str = get(spl_file, 'String');
    	if (isempty(data_str))
      		return;
    	end
    	dataname = data_str{selected};

    	handles = guidata(hObject);
		data_bc = handles.data_corrected;

    	file = fopen(fullfile(pathname, [dataname(1:end-4), '_BC.dat']), 'wt+');
    	for i = 1:length(data_bc)
    		fprintf(file, '%10.2f\t', data_bc(i,:));
    		fprintf(file, '\r\n');
    	end
    	fclose(file);
    	guidata(hObject, handles);

	end

%% I-d/I-V functions ----------------------------------------------------------------------------------------------------

	function idv_initial_Callback(hObject, eventdata)

		box on
		xlim([-1.5 1.5])
		ylim([-0.5 0.5])
		yticks(-0.5:0.2:0.5)
	    legend off;
	    grid on;
		xlabel('Voltage (V)')
		ylabel('Current (\muA)')

	end

	function loadbutton_Callback(hObject, eventdata)

		set(cnum, 'String', 0);
		set(tnum, 'String', 0);
		set(l_file, 'String', []);
		set(l_file, 'Value', 1);
		axes(ax)
		cla(ax,'reset');
		idv_initial_Callback

		[files, pathname, filterindex] = uigetfile({'*.dat'; '*.txt'}, 'MultiSelect','on');
		if(pathname == 0)
    		return;
  		end
		path(path, pathname);
		if(iscell(files) == 0)
			files = {files};
		end

		filecount = length(files);
		set(tnum, 'String', filecount);
		set(l_file, 'String', files);

		dname1 = files{1};

		idx = strfind(dname1, 'UI');
    	if (isempty(idx))
    		set(tymin, 'String', -0.01);
    		set(tymax, 'String', 0.1);
    		axes(ax)
    		xlabel('Distance (\AA)', 'Interpreter', 'latex')
			ylabel('Current (\muA)')
    	else
    		set(tymin, 'String', -0.5)
    		set(tymax, 'String', 0.5)
    		set(txmin, 'String', -1.5)
    		set(txmax, 'String', 1.5)
    		axes(ax)
    		xlabel('Voltage (V)')
			ylabel('Current (\muA)')

    	end

	end

	function listbox_Callback(hObject, eventdata)

		selected = get(l_file, 'Value');
    	data_str = get(l_file, 'String');

    	set(cnum, 'String', selected);

    	if (isempty(data_str) == 1)
      		return;
    	end
    	
    	xmin = str2num(get(txmin, 'String'));
		xmax = str2num(get(txmax, 'String'));
		if (xmin >= xmax)
			return;
		end
		ymin = str2num(get(tymin, 'String'));
		ymax = str2num(get(tymax, 'String'));
		if (ymin >= ymax)
			return;
		end

    	dataname = data_str{selected};
    	isp = strfind(dataname, 'SP');
		if(~isempty(isp))
			return;
		end
    	data = load(dataname);

    	idx = strfind(dataname, 'UI');
    	if (isempty(idx))
	    	x = data(:,1);
	      	y = data(:,2);
	      	y_scaled = y./10.^-6;
	      	axes(ax)
	      	cla(ax,'reset');
	      	
	     	[v_max,idmx] = max(x);
	      	% approach curve (red)
	      	ap_x = x(1:idmx);
	      	ap_y = y_scaled(1:idmx);
	      	max_ap = max(ap_x);
	      	dx_ap = (ap_x - max_ap)*-1*0.26./0.0003;

	      	% figure out x range
    		idx_ap = find(ap_y<ymax,1, 'last');
    		ap_xmin = dx_ap(idx_ap);
	    
	      	% retract curve (blue)
	      	rt_x = x(idmx:end);
	      	% hy_ap = 0.1 * max(ap_y);
	      	rt_y = y_scaled(idmx:end); 
	      	max_rt = max(rt_x);
	      	dx_rt = (rt_x - max_rt)*-1*0.26./0.0003;

	      	% figure out x range
    		idx_rt = find(rt_y<ymax,1, 'last');
    		rt_xmin = dx_rt(idx_rt);
    		id_xmin = min(ap_xmin, rt_xmin) -5;
    		id_xmax = max(dx_rt) + 5;


	    	plot(dx_ap, ap_y, 'r', 'LineWidth', 1.5)
	    	hold on
	    	plot(dx_rt, rt_y, 'b', 'LineWidth', 1.5)
	    	hold off
	    	xlim([id_xmin id_xmax])
	    	ylim([ymin ymax])
	    	xlabel('Distance (\AA)', 'Interpreter', 'latex')
			ylabel('Current (\muA)')
			grid on

			xl = ax.XLim;
			set(txmin, 'String', xl(1));
			set(txmax, 'String', xl(2));
		else
			% split the two lines of I-V curve
			idx1 = [1:2:length(data)];
			data1 = data(idx1,:);
			x1 = data1(:,1);
	      	y1 = data1(:,2);
	      	yd1 = data1(:,3);
	      	y1_scaled = y1./10.^-6;
	      	yd1_scaled = yd1./10.^-6;

			idx2 = [2:2:length(data)];
			data2 = data(idx2,:);
	      	x2 = data2(:,1);
	      	y2 = data2(:,2);
	      	yd2 = data2(:,3);
	      	y2_scaled = y2./10.^-6;
	      	yd2_scaled = yd2./10.^-6;

	      	axes(ax)
			cla(ax,'reset')
	    	yyaxis left
	    	plot(ax, x1, y1_scaled, 'LineWidth', 1.2)
	    	hold on
	    	plot(ax, x2, y2_scaled, 'LineWidth', 1.2)
	    	hold off
	    	xlim([xmin xmax])
	    	ylim([ymin ymax])
	    	yticks(ymin:0.2:ymax)
	    	xlabel('Voltage (V)')
			ylabel('Current (\muA)')
			set(gca,'XMinorTick','on','YMinorTick','on')
			grid on
			yyaxis right
			plot(ax, x1, yd1_scaled, 'LineWidth', 1.2)
			hold on
			plot(ax, x2, yd2_scaled, 'LineWidth', 1.2)
			hold off
			ylabel('dI/ dU (\muS)')
			ylim auto
			set(gca,'XMinorTick','on','YMinorTick','on')
			grid on
		end

	end

	function range_Callback(hObject, eventdata)

		xmin = str2num(get(txmin, 'String'));
		xmax = str2num(get(txmax, 'String'));
		if (xmin >= xmax)
			return;
		end
		ymin = str2num(get(tymin, 'String'));
		ymax = str2num(get(tymax, 'String'));
		if (ymin >= ymax)
			return;
		end

		selected = get(l_file, 'Value');
    	data_str = get(l_file, 'String');
    	if (isempty(data_str) == 1)
      		return;
    	end
    	dataname = data_str{selected};
    	idx = strfind(dataname, 'Id');
    	if (isempty(idx))
			axes(ax)
			xlim([xmin xmax])
			yyaxis left
			ylim([ymin ymax])
		%	yticks(ymin:0.2:ymax)
			xticks auto
		else 
			axes(ax)
			xlim([xmin xmax])
			ylim([ymin ymax])
		end

	end

	function path_Callback(hObject, eventdata)

		folder_name = uigetdir;
		if (folder_name == 0)
			return;
		end
		set(tsave, 'String', folder_name);
		
	end

	function save_Callback(hObject, eventdata)

		pathname = get(tsave, 'String');
		if (isempty(pathname ==1) | exist(pathname, 'dir') == 0)
			msgbox('Please assign a valid folder!','Error','error');
			return;
		end
		selected = get(l_file, 'Value');
    	data_str = get(l_file, 'String');
    	if (isempty(data_str) == 1)
      		return;
    	end
    	dataname = data_str{selected};
    	data = load(dataname);

    	file = fopen(fullfile(pathname, [dataname(1:end-4), '_selected.dat']), 'wt+');
    	for i = 1:length(data)
    		fprintf(file, '%5.12f\t', data(i,:));
    		fprintf(file, '\r\n');
    	end
    	fclose(file);

	end

%% peak-fitting functions ----------------------------------------------------------------------------------------------------
	function pfp_initial_Callback(hObject, eventdata)

		box on
		legend off;
		grid on;
		xlabel('Number')
		xlim([0 50])
		set(gca,'XMinorTick','on','YMinorTick','on')
		yyaxis left
		ylim([1300 1400])
		ylabel('Peak Center (1/cm)')
		yyaxis right
		ylim([0 100])
		ylabel('Intensity (cps)')
		
	end
	
	function d = pf_table_initial(hObject, eventdata)

		d = cell(5000,3);
		for i = 1:size(d,1)
			d{i,1} = 0;
			d{i,2} = 0;
			d{i,3} = false;  
		end 
	end 

	function pf_load_Callback(hObject, eventdata)

		set(pf_cnum, 'String', 0);
		set(pf_tnum, 'String', 0);
		set(pfl_file, 'String', []);
		set(pfl_file, 'Value', 1);
		axes(pf_ax)
		cla(pf_ax,'reset');
		sp_initial_Callback
		axes(pfp_ax)
		cla(pfp_ax,'reset');
		pfp_initial_Callback
		d = pf_table_initial;
		set(pfp_tabel, 'Data', d);

		[files, pathname, filterindex] = uigetfile('/home/gong/E20/MJS/Data-Yuxiang/Data/Junction/*.dat', 'MultiSelect','on');

		if(pathname == 0)
    		return;
  		end
		path(path, pathname);
		if(iscell(files) == 0)
			files = {files};
		end

		filecount = length(files);
		set(pf_tnum, 'String', filecount);
		set(pfl_file, 'String', files);

	end

	function pf_list_Callback(hObject, eventdata) % kernel function

	% load data and substract the baseline
		selected = get(pfl_file, 'Value');
    	data_str = get(pfl_file, 'String');

    	if (isempty(data_str))
      		return;
    	end
    	
    	xmin = str2num(get(pf_txmin, 'String'));
		xmax = str2num(get(pf_txmax, 'String'));
		if (xmin >= xmax)
			return;
		end

		dataname = data_str{selected};

		if (strcmp(dataname, '0')| strcmp(dataname, 'NO DATA FOUND ...'))
    		return;
    	end

		idx_type = regexp(dataname, 'SP');
		if(isempty(idx_type))
			msgbox('Please load spectrum data only !','Error','error');
			return;
		end

		set(pf_cnum, 'String', selected);
    	data = load(dataname);
    	X = data(:,1);
    	Y = data(:,2);
    	axes(pf_ax)
    	[BL, Inty] = RCF(data, xmin, xmax);
    	plot(pf_ax, X, Inty, 'LineWidth', 1.5)
    	xlim([xmin xmax])
    	set(gca,'XMinorTick','on','YMinorTick','on')
    	grid on
    	xlabel('Raman Shift (1/cm)')
		ylabel('Intensity (cps)')
		hold on

	% peak fitting with parameters
		rangel = str2num(get(pf_sxmin, 'String'));
		ranger = str2num(get(pf_sxmax, 'String'));
		para1 = str2num(get(pf_pinit, 'String'));
		para2 = str2num(get(pf_winit, 'String'));
		para3 = str2num(get(pf_iinit, 'String'));
		set(pf_pinit, 'String', mean([rangel ranger]));

		if (rangel >= ranger)
			return;
		end
		% plot vertical line indicate the range
		vline([rangel ranger], {'g', 'g'});
		pf_data = [X, Inty];
		paraguess = [para1 para2 para3];
		[xp, peak, paras] = peak_fit(pf_data, rangel, ranger, paraguess);
		plot(xp, peak, 'LineWidth', 1.0)
		hold off
		% if (abs(paras(1)-para1) > 100)|(abs(paras(3) - para3) > 100)
		% 	msgbox('Bad fitting! Please change parameters !','Error','error');
		% end

		set(pf_para1, 'String', paras(1));
		set(pf_para2, 'String', abs(paras(2)));
		set(pf_para3, 'String', paras(3));

		handles = guidata(hObject);
		handles.pf_data = pf_data;
		handles.paras = cellstr(char(num2str(paras(1)), num2str(abs(paras(2))), num2str(paras(3))));

	% save parameters to table
		handles.t_data = get(pfp_tabel, 'Data');
		handles.t_data{selected, 1} = paras(1);
		handles.t_data{selected, 2} = paras(3);
		set(pfp_tabel, 'Data', handles.t_data);
	% plot in tendency axes
		% t_data = get(pfp_tabel, 'Data');
		n = size(handles.t_data,1);
		m = 1;
		for i = 1:n
			if (~handles.t_data{i,3} & handles.t_data{i,1}~=0 & handles.t_data{i,2}~=0)
				pf_peak(m) = handles.t_data{i,1};
				pf_Inty(m) = handles.t_data{i,2};
				m = m+1;
			end
		end
		
		if  (exist('pf_peak')==0 | exist('pf_Inty')==0)
			return;
		end

		axes(pfp_ax);
		yyaxis left
		plot(pfp_ax, [1:1:length(pf_peak)], pf_peak, 's-', 'LineWidth', 1.2,...
			'MarkerSize',5, 'MarkerEdgeColor','b', 'MarkerFaceColor','b')
		ylabel('Peak Center (1/cm)')
		set(gca,'XMinorTick','on','YMinorTick','on')

		yyaxis right
		plot(pfp_ax, [1:1:length(pf_Inty)], pf_Inty, 's-', 'LineWidth', 1.2,...
			'MarkerSize',5, 'MarkerEdgeColor','r', 'MarkerFaceColor','r')
		ylabel('Intensity (cps)')
		set(gca,'XMinorTick','on','YMinorTick','on')
		xlim auto

		guidata(hObject, handles);

	end

	function pf_savepath_Callback(hObject, eventdata)

		folder_name = uigetdir;
		if (folder_name == 0)
			return;
		end
		set(pf_tsave, 'String', folder_name);
		
	end

	function pf_save_Callback(hObject, eventdata)

		pathname = get(pf_tsave, 'String');
		if (isempty(pathname ==1) | exist(pathname, 'dir') == 0)
			msgbox('Please assign a valid folder!','Error','error');
			return;
		end
		selected = get(pfl_file, 'Value');
    	data_str = get(pfl_file, 'String');
    	if (isempty(data_str))
      		return;
    	end
    	dataname = data_str{selected};

    	handles = guidata(hObject);
		data_bc = handles.pf_data;
		items = cellstr(char('Peak Center: ', 'FWHM: ', 'Intensity: '));
		parameters = handles.paras;

		header = cell(length(items), size(data_bc,2));
 		header(1:length(items), 1) = items;
  		header(1:length(items), 2) = parameters;

    	file = fopen(fullfile(pathname, [dataname(1:end-4), '_PF.dat']), 'wt+');
    	m = size(header,1);
  		for i = 1:m
		    fprintf(file, '%15s ', header{i, :});
		    fprintf(file, '\n');
		end
		
		fprintf(file, '\n');

		for j = (m+2):size(data_bc,1)
			fprintf(file, '%15.3f ', data_bc(j,:));
			fprintf(file, '\n');
		end
  		fclose(file);

    	guidata(hObject, handles);

	end

	function pfp_savepath_Callback(hObject, eventdata)

		folder_name = uigetdir;
		if (folder_name == 0)
			return;
		end
		set(pfp_tsave, 'String', folder_name);
		
	end

	function pfp_save_Callback(hObject, eventdata)

		pathname = get(pfp_tsave, 'String');
		if (isempty(pathname ==1) | exist(pathname, 'dir') == 0)
			msgbox('Please assign a valid folder!','Error','error');
			return;
		end

		handles = guidata(hObject);
		n = size(handles.t_data,1);
		m = 1;
		for i = 1:n
			if (~handles.t_data{i,3} & handles.t_data{i,1}~=0 & handles.t_data{i,2}~=0)
				pf_peak(m) = handles.t_data{i,1};
				pf_Inty(m) = handles.t_data{i,2};
				m = m+1;
			end
		end
		
		if  (exist('pf_peak')==0 | exist('pf_Inty')==0)
			return;
		end

		idx = [1:1:length(pf_peak)]';
		data = [idx pf_peak' pf_Inty'];

    	file = fopen(fullfile(pathname, 'parameters.txt'), 'wt+');
		
    	for i = 1:size(data,1)
    		fprintf(file, '%10.2f\t', data(i,:));
    		fprintf(file, '\r\n');
    	end
    	fclose(file);

    	guidata(hObject, handles);

	end

end