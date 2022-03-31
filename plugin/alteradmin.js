var permission_error = "Your rank is lower than "

const permissions = {
	get_mapped: function(level){
    	if (level === "Moderator"){
        	return 4
        }    
    	if (level === "Administrator"){
        	return 5
        }
    	if (level === "SeniorAdmin"){
        	return 6
        }
    	if (level === "Owner"){
        	return 7
        }
    	return 1
    },
};

let commands = [{
    name: "teamswitch",
    description: "Switches a player's team",
    alias: "tms",
    permission: "Administrator",
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        if (permissions.get_mapped(gameEvent.Origin.Level) > permissions.get_mapped(gameEvent.Target.Level)){
            server.RconParser.SetDvarAsync(server.RemoteConnection, "g_switchteam", ''+ cid.toString())
            gameEvent.Origin.Tell('^2'+ gameEvent.Target.Name +' ^7has been team switched');
        }
        else
            gameEvent.Origin.Tell(permission_error + gameEvent.Target.Name + " you: " + gameEvent.Origin.Level + " them: " +  gameEvent.Target.Level);
    }
}, {
    name: "spectate",
    description: "Switches a player to spectator mode",
    alias: "spec",
    permission: "Administrator",
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        if (permissions.get_mapped(gameEvent.Origin.Level) > permissions.get_mapped(gameEvent.Target.Level)){
            server.RconParser.SetDvarAsync(server.RemoteConnection, "g_switchspec", ''+ cid.toString())
            gameEvent.Origin.Tell('^2'+ gameEvent.Target.Name +' ^7has been swichted to spectator mode');
        }
        else
            gameEvent.Origin.Tell(permission_error + gameEvent.Target.Name);
    }
}, {
    name: "teleport",
    description: "Teleports a player to another player (bugged)",
    alias: "tp",
    permission: "SeniorAdmin",
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        server.RconParser.SetDvarAsync(server.RemoteConnection, "g_teleport", ''+ cid.toString())
    }
}, {
    name: "balance",
    description: "Balances teams",
    alias: "blc",
    permission: "Administrator",
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        server.RconParser.SetDvarAsync(server.RemoteConnection, "g_balance")
        gameEvent.Origin.Tell('Balancing teams ...');
    }
}, {
    name: "spawn",
    description: "Spawns a player",
    alias: "spw",
    permission: "Administrator",
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        server.RconParser.SetDvarAsync(server.RemoteConnection, "b3_spawn", ''+ cid.toString())
        gameEvent.Origin.Tell('^2'+ gameEvent.Target.Name +' ^7is spawned');
    }
}

];

let plugin = {
    author: 'sepehr-gh',
    version: 1.4,
    name: 'RepZ Alteradmin',
    logger: null,

    onEventAsync: function (gameEvent, server) {
    	this.logger.WriteDebug("Event for alteradmin");
    },

    onLoadAsync: function (manager) {
        this.logger = _serviceResolver.ResolveService("ILogger");
        this.logger.WriteInfo("RepZ Alteradmin loaded");
    },

    onUnloadAsync: function () {
    },

    onTickAsync: function (server) {
    }
};
