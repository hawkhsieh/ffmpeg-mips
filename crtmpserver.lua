configuration=
{
	daemon=true,
	pathSeparator="/",
	logAppenders=
	{
		{
			name="console appender",
			type="coloredConsole",
			level=0
		},
		{
			name="file appender",
			type="file",
			level=0,
			fileName="/var/log/.crtmpserver.log",
			fileHistorySize=10,
			fileLength=1024*256,
			singleLine=true
		}
	},
	applications=
	{
		rootDirectory="applications",
		{
			name="proxypublish",
			description="proxypublish",
			acceptors = 
			{
				-- enable for local life view
				{
					ip="0.0.0.0",
					port=1935,
					protocol="inboundRtmp"
				}
			},
			abortOnConnectError=true,
			targetServers = 
			{
				{
					targetUri="rtmp://admin:admin@192.168.1.1:1935/flvplayback",
					targetStreamType="live",
					emulateUserAgent="My user agent",
					localStreamName="rtsp_relay",
					keepAlive=true
				}
			},
			externalStreams = 
			{
				{
					uri="rtsp://admin:@127.0.0.1:554/play1.sdp",
					localStreamName="rtsp_relay",
					forceTcp=true
				}
			},
			validateHandshake=true,
			keyframeSeek=true,
			seekGranularity=1.5,
			clientSideBuffer=12,
			enableCheckBandwidth=true,
			autoReconn=true,
			--[[forceAuth=true,
			authentication=
			{
				rtmp={
					type="adobe",
					encoderAgents=
					{
						"FMLE/3.0 (compatible; FMSc/1.0)",
						"crtmpserver",
					},
					usersFile="userconfig"
				}
			}]]--
		}
	}
}

