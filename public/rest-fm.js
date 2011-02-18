Ext.setup({
    //tabletStartupScreen: 'tablet_startup.png',
    //phoneStartupScreen: 'phone_startup.png',
    //icon: 'icon.png',
    glossOnIcon: false,
    onReady: function() {

		var currentTimer = null;

		function updateButtons(status) {
			skipButton.setDisabled(!status);
			loveButton.setDisabled(!status);
			banButton.setDisabled(!status);
		}

		function updateStatus() {
			Ext.Ajax.request({
  			loadMask: true,
  			url: '/info/_json',
				success: function(resp) {
					// resp is the XmlHttpRequest object
					var status = Ext.decode(resp.responseText);
					$("#coverImage").attr('src', status['image']);
					if(status['stopped'] == false && status['paused'] == 'f') {
						playPauseButton.setText('Pause');
						updateButtons(true);
					} else if(status['paused'] == 't') {
						playPauseButton.setText('Resume');
						updateButtons(true);
					} else {
						playPauseButton.setText('Play');
						updateButtons(false);
					}
					// Something has changed, we just updated the gui,
					// So cancel the next timeout and set another one
					if(currentTimer != null) {
						clearTimeout(clearTimeout);
					}
					var nextWakeUp = (status['remain']+0.2)*1000;
					console.log("%s remaining, waking up in %d", status['remain'], nextWakeUp);
					// Plan next update exactly at the end of the song
					currentTimer = setTimeout(updateStatus, nextWakeUp);
				}
			});
		}
			var playPauseButton = new Ext.Button({
				ui: 'small',
				text: 'Play',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/pause',
						success: updateStatus,
						failure: updateStatus });
					}
				}
				});
			var skipButton = new Ext.Button({
				ui: 'small',
				listeners: {
					tap: function() {
					Ext.Ajax.request({
    				url: '/api/skip',
						success: updateStatus,
						failure: updateStatus
					 });
					}
				},
				text: (Ext.is.Phone ? '&#x23e9;' : 'Skip')});
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
						dock: 'bottom',
						xtype: 'toolbar',
						ui: 'light',
						items: [
							[playPauseButton, skipButton, loveButton, spacer, banButton]
						]
					}
				],
				listeners: { afterrender: updateStatus },
				html:"<center><img id='coverImage' class='myImage' /></center>"
			});
			updateStatus();
		}});

