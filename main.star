participants = import_module("./src/participants.star")
bridges = import_module("./src/bridges.star")
bootnodes = import_module("./src/bootnodes.star")
input_parser = import_module("./src/utils/input_parser.star")

def run(plan, args={}):
    args_with_right_defaults = input_parser.input_parser(plan, args)

    num_bridges = len(args_with_right_defaults.bridges)
    num_bootnodes = len(args_with_right_defaults.bootnodes)
    num_participants = len(args_with_right_defaults.participants)
    plan.print(
        "Launching network with {} participants, {} bridges, {} bootnodes".format(
            num_participants, num_bridges, num_bootnodes
        )
    )

    (all_bootnodes, bootnode_enrs) = bootnodes.launch(
        plan,
        args_with_right_defaults.bootnodes,
    )

    all_participants = participants.launch(
        plan,
        args_with_right_defaults.participants,
        bootnode_enrs,
    )

    all_bridges = bridges.launch(
        plan,
        args_with_right_defaults.bridges,
        bootnode_enrs,
    )

    plan.print(
        "Launched network with {} participants, {} bridges, {} bootnodes".format(
            num_participants, num_bridges, num_bootnodes
        )
    )
