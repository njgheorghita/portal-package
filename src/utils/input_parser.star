DEFAULT_IMAGES = {
    "trin": "portalnetwork/trin:latest",
    "bridge": "portalnetwork/trin:latest-bridge",
    "fluffy": "statusim/nimbus-fluffy:amd64-master-latest",
}


def input_parser(plan, input_args):
    result = default_input_args()
    for attr in input_args:
        if attr == "participants":
            participants = []
            for participant in input_args[attr]:
                new_participant = default_participant()
                for sub_attr, sub_value in participant.items():
                    # override default values with values defined in config.yaml
                    new_participant[sub_attr] = sub_value
                participants.append(new_participant)
            result[attr] = participants
        if attr == "bootnodes":
            bootnodes = []
            for bootnode in input_args[attr]:
                new_bootnode = default_bootnode()
                for sub_attr, sub_value in bootnode.items():
                    # override default values with values defined in config.yaml
                    new_bootnode[sub_attr] = sub_value
                bootnodes.append(new_bootnode)
            result[attr] = bootnodes
        if attr == "bridges":
            bridges = []
            for bridge in input_args[attr]:
                new_bridge = default_bridge()
                for sub_attr, sub_value in bridge.items():
                    # override default values with values defined in config.yaml
                    new_bridge[sub_attr] = sub_value
                bridges.append(new_bridge)
            result[attr] = bridges

    return struct(
        participants=[
            struct(
                client_type=participant["client_type"],
                min_cpu=participant["min_cpu"],
                max_cpu=participant["max_cpu"],
                min_mem=participant["min_mem"],
                max_mem=participant["max_mem"],
                private_key=participant["private_key"],
                image=DEFAULT_IMAGES[participant["client_type"]],
            )
            for participant in result["participants"]
        ],
        bootnodes=[
            struct(
                client_type=bootnode["client_type"],
                min_cpu=bootnode["min_cpu"],
                max_cpu=bootnode["max_cpu"],
                min_mem=bootnode["min_mem"],
                max_mem=bootnode["max_mem"],
                private_key=bootnode["private_key"],
                image=DEFAULT_IMAGES[bootnode["client_type"]],
            )
            for bootnode in result["bootnodes"]
        ],
        bridges=[
            struct(
                client_type=bridge["client_type"],
                mode=bridge["mode"],
                min_cpu=bridge["min_cpu"],
                max_cpu=bridge["max_cpu"],
                min_mem=bridge["min_mem"],
                max_mem=bridge["max_mem"],
                private_key=bridge["private_key"],
                image=DEFAULT_IMAGES[bridge["client_type"]],
            )
            for bridge in result["bridges"]
        ],
    )

def default_input_args():
    participant = default_participant()
    bootnode = default_bootnode()
    bridge = default_bridge()
    return {
        "participants": [participant,],
        "bootnodes": [bootnode,],
        "bridges": [bridge,],
    }

def default_participant():
    return {
        "client_type": "trin",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x0101010101010101010101010101010101010101010101010101010101010101",
        "image": DEFAULT_IMAGES["trin"],
    }

def default_bootnode():
    return {
        "client_type": "trin",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x1101010101010101010101010101010101010101010101010101010101010101",
        "image": DEFAULT_IMAGES["trin"],
    }

def default_bridge():
    return {
        "client_type": "bridge",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x2101010101010101010101010101010101010101010101010101010101010101",
        "mode": "single:b1",
        "image": DEFAULT_IMAGES["bridge"],
    }
