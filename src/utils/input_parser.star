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
                client_type = new_participant["client_type"]
                if "client_type" in participant:
                    client_type = participant["client_type"]
                if "image" not in participant:
                    new_participant["image"] = DEFAULT_IMAGES[client_type]
                # override default values with values defined in config.yaml
                for sub_attr, sub_value in participant.items():
                    new_participant[sub_attr] = sub_value
                participants.append(new_participant)
            result[attr] = participants
        if attr == "bootnodes":
            bootnodes = []
            for bootnode in input_args[attr]:
                new_bootnode = default_bootnode()
                client_type = new_bootnode["client_type"]
                if "client_type" in bootnode:
                    client_type = bootnode["client_type"]
                if "image" not in bootnode:
                    new_bootnode["image"] = DEFAULT_IMAGES[client_type]
                # override default values with values defined in config.yaml
                for sub_attr, sub_value in bootnode.items():
                    new_bootnode[sub_attr] = sub_value
                bootnodes.append(new_bootnode)
            result[attr] = bootnodes
        if attr == "bridges":
            bridges = []
            for bridge in input_args[attr]:
                new_bridge = default_bridge()
                client_type = new_bridge["client_type"]
                if "client_type" in bridge:
                    client_type = bridge["client_type"]
                if "image" not in bridge:
                    new_bridge["image"] = DEFAULT_IMAGES[client_type]
                if "extra_env_vars" in bridge:
                    new_bridge["extra_env_vars"] = bridge["extra_env_vars"]
                else:
                    new_bridge["extra_env_vars"] = load_env_vars()
                # override default values with values defined in config.yaml
                for sub_attr, sub_value in bridge.items():
                    new_bridge[sub_attr] = sub_value
                bridges.append(new_bridge)
            result[attr] = bridges
        if attr == "glados":
            new_glados = default_glados()
            client_type = new_glados["client_type"]
            if "client_type" in input_args[attr][0]:
                client_type = input_args[attr][0]["client_type"]
            new_glados["image"] = DEFAULT_IMAGES[client_type]
            if "extra_env_vars" in input_args[attr][0]:
                new_glados["extra_env_vars"] = input_args[attr][0]["extra_env_vars"]
            else:
                new_glados["extra_env_vars"] = load_env_vars()
            result[attr] = new_glados

    return struct(
        participants=[
            struct(
                client_type=participant["client_type"],
                min_cpu=participant["min_cpu"],
                max_cpu=participant["max_cpu"],
                min_mem=participant["min_mem"],
                max_mem=participant["max_mem"],
                private_key=participant["private_key"],
                image=participant["image"],
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
                image=bootnode["image"],
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
                image=bridge["image"],
                extra_env_vars=bridge["extra_env_vars"],
            )
            for bridge in result["bridges"]
        ],
        glados=struct(
            client_type=result["glados"]["client_type"],
            image=result["glados"]["image"],
            extra_env_vars=result["glados"]["extra_env_vars"],
        ),
    )

def default_input_args():
    # by default, we have no participants, bootnodes, bridges, or glados
    # these can be configured in the config.yaml file
    return {
        "participants": [],
        "bootnodes": [],
        "bridges": [],
        "glados": [],
    }

def default_participant():
    return {
        "client_type": "trin",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x0101010101010101010101010101010101010101010101010101010101010101",
    }

def default_bootnode():
    return {
        "client_type": "trin",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x1101010101010101010101010101010101010101010101010101010101010101",
    }

def default_bridge():
    return {
        "extra_env_vars": {},
        "client_type": "bridge",
        "min_cpu": 0,
        "max_cpu": 100,
        "min_mem": 0,
        "max_mem": 100,
        "private_key": "0x2101010101010101010101010101010101010101010101010101010101010101",
        "mode": "single:b1",
    }

def default_glados():
    return {
        "extra_env_vars": {},
        "client_type": "trin",
    }

def load_env_vars():
    env_vars = read_file("../../.secrets.json")
    env_vars = json.decode(env_vars)
    return env_vars
