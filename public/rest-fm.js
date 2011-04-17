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
						clearTimeout(currentTimer);
					}
					// Wait one second after the remaining time
					var nextWakeUp = (status['remain']+1)*1000;
					Ext.defer(updateStatus, nextWakeUp);
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
			var sleeping = false;
			var picker = new Ext.Picker({
					slots: [
							{
									name : 'sleep_duration',
									title: 'Sleep for',
									data : [
											{text: '1800s', value: 1800},
											{text: '3600s', value: 3600},
											{text: '600s', value: 600},
											{text: 'Other', value: -1}
									]
							}
					],
					listeners: {
						change: function(picker, the, slot) {
							d = the['sleep_duration'];
							sleepButton.setText("Abort sleep");
							sleeping = true;
							Ext.Ajax.request({
								url: '/sleep/'+d });
						} 
					}
			});

			var sleepButton = new Ext.Button({
				ui: 'small',
				listeners: {
					tap: function() {
						if(! sleeping) {
							picker.show();
						} else {
							Ext.Ajax.request({
								url: '/sleep/-1' });
							sleepButton.setText("Sleep");
						}
				}},
				text: 'Sleep'});

			var spacer = new Ext.Spacer({flex:1});
							
			var homePanel = new Ext.Panel({
				fullscreen: true,
				dockedItems: [
					{
						dock: 'top',
						xtype: 'toolbar',
						title: 'REST.fm',
					},
					{
						dock: 'bottom',
						xtype: 'toolbar',
						ui: 'light',
						items: [
							[playPauseButton, skipButton, loveButton, spacer, sleepButton]
						]
					}
				],
				html:"<center><img id='coverImage' class='myImage' /></center>"
			});
			updateStatus();
		}});

