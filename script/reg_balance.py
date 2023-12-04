
def reg_balance(ts: int, rs: int):
    """
        ts: Total number of stages
        rs: Registered stages
    """
    stages = [0] * ts



    return stages


if __name__ == "__main__":
    scenarios = []
    for ts in range(3, 8):
        for rs in range(0, ts + 1):
            rb = reg_balance(ts, rs)
            scenarios.append((ts, rs, rb))

    # Print
    print("TS\tRS\tPipeline")
    for s in scenarios:
        print(f"{s[0]}\t{s[1]}\t{s[2]}")