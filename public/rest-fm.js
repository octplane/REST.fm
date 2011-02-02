Ext.setup({
    //tabletStartupScreen: 'tablet_startup.png',
    //phoneStartupScreen: 'phone_startup.png',
    //icon: 'icon.png',
    glossOnIcon: false,
    onReady: function() {
			var playPauseButton = new Ext.Button({
				ui: 'small', flex:1,
				text: 'Play',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/pause' });
					}
				}
				});
			var skipButton = new Ext.Button({
				ui: 'small', flex:1,
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/skip' });
					}
				},
				text: 'Skip'});
			var loveButton = new Ext.Button({
				ui: 'small', flex:1,
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/love' });
					}
				},
				text: 'Love'});
			var spacer = new Ext.Spacer({flex:1});
			var banButton = new Ext.Button({
				ui: 'small', flex:1,
				text: 'Ban'});
	
				
			var panel = new Ext.Container({
				fullscreen: true,
				cardswitchAnimation: 'slide',
				layout: { type: 'hbox', align: 'stretch'},
				items: [playPauseButton, skipButton, loveButton, spacer, banButton]
			});
		}});
