Ext.setup({
    //tabletStartupScreen: 'tablet_startup.png',
    //phoneStartupScreen: 'phone_startup.png',
    //icon: 'icon.png',
    glossOnIcon: false,
    onReady: function() {
			var playPauseButton = new Ext.Button({
				ui: 'small',
				text: 'Play',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/pause' });
					}
				}
				});
			var skipButton = new Ext.Button({
				ui: 'small',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/skip' });
					}
				},
				text: 'Skip'});
			var loveButton = new Ext.Button({
				ui: 'small',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/love' });
					}
				},
				text: 'Love'});
			var spacer = new Ext.Spacer({flex:1});
			var banButton = new Ext.Button({
				ui: 'plain',
				iconCls: 'trash',
				iconMask: true
				});
	
							
			var homePanel = new Ext.Panel({
				fullscreen: true,
				dockedItems: [
					{
						dock: 'top',
						xtype: 'toolbar',
						title: 'REST.fm'
					},
					{
						dock: 'top',
						xtype: 'toolbar',
						ui: 'light',
						items: [
							[playPauseButton, skipButton, loveButton, spacer, banButton]
						]
					}
				],
				html: 
			});
		}});
