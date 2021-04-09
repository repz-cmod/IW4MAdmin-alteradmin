var permission_error = "Your rank is lower than "

let commands = [{
    name: "teamswitch",
    description: "Switches a player's team",
    alias: "ts",
    permission: "Administrator",
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        if (gameEvent.Origin.Level > gameEvent.Target.Level)
            server.RconParser.SetDvarAsync(server.RemoteConnection, "g_switchteam", ''+ cid.toString())
        else
            gameEvent.Origin.Tell(permission_error + gameEvent.Target.Name);
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
        if (gameEvent.Origin.Level > gameEvent.Target.Level)
            server.RconParser.SetDvarAsync(server.RemoteConnection, "g_switchspec", ''+ cid.toString())
        else
            gameEvent.Origin.Tell(permission_error + gameEvent.Target.Name);
    }
}, {
    name: "teleport",
    description: "Teleports a player to another player",
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
    targetRequired: true,
    arguments: [{
        name: "Target Player",
        required: true
    }],
    execute: (gameEvent) => {
        var server = gameEvent.Owner;
        var cid = gameEvent.Target.ClientNumber;
        server.RconParser.SetDvarAsync(server.RemoteConnection, "g_balance", ''+ cid.toString())
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
    }
}

];

let plugin = {
    author: 'sepehr-gh',
    version: 1.0,
    name: 'RepZ Alteradmin',

    onEventAsync: function (gameEvent, server) {
    },

    onLoadAsync: function (manager) {
        this.logger = manager.GetLogger(0);
        this.logger.WriteDebug("RepZ Alteradmin loaded");
    },

    onUnloadAsync: function () {
    },

    onTickAsync: function (server) {
    }
};