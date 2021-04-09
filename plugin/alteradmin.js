let commands = [
    {
        name: "teamswitch",
        description: "Switches a player team",
        alias: "pps",
        permissions: "Administrator",

        execute: (gameEvent) => {
            var server = gameEvent.Owner;
            var cid = gameEvent.Target.ClientNumber;
            if (gameEvent.Origin.Level > gameEvent.Target.Level){
                server.SetDvarAsync("g_switchteam", ''+ cid)
                // server.RconParser.ExecuteCommandAsync(server.RemoteConnection, 'set sv_b3Execute !quickmaths ' + cid + ' ' + message).Result;
            }
        }
    }
]

let plugin = {
    author: 'sepehr-gh',
    version: 1.1,
    name: 'Alteradmin',

    onEventAsync: function(gameEvent, server) {},

    onLoadAsync: function(manager) {},

    onUnloadAsync: function() {},

    onTickAsync: function(server) {}
};