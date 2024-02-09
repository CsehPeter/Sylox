

def round(f: float):
    d2 = int(10 * f) % 10
    val = int(f)
    if d2 >= 5:
        val += 1
    return val


##  ts: Total number of stages
##  rs: Registered stages
def reg_balance(ts: int, rs: int):
    stages = [0] * ts
    if rs == 0:
        return stages

    stages[-1] = 1
    ts -= 1
    rs -= 1

    if rs == 0:
        return stages


    inc = ts / rs
    f_acc = 0.0
    i_acc = 0

    while(i_acc < ts):
        f_acc += inc

        lo = i_acc              # Low index of the range
        hi = round(f_acc) - 1   # High index of the range

        idx = lo + int((hi - lo) / 2)    # Middle element of the range
        stages[idx] = 1

        i_acc = round(f_acc)
        #print(f"acc: {i_acc}, lo: {lo}, hi: {hi}, idx: {idx}")

    return stages


def test():
    scenarios = []
    for ts in range(3, 8):
        for rs in range(0, ts + 1):
            rb = reg_balance(ts, rs)
            scenarios.append((ts, rs, rb))

    # Print
    print("TS\tRS\tPipeline")
    for s in scenarios:
        print(f"{s[0]}\t{s[1]}\t{s[2]}")


if __name__ == "__main__":
    test()