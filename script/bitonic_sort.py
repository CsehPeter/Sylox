# from: https://en.wikipedia.org/wiki/Bitonic_sorter

import math, copy, itertools, sys, os, random

####################################################################################################
## Core
####################################################################################################

## Comparator: compare and switch 2 elements
def cmp(a: int, b: int):
    if a > b:
        return (b, a)
    else:
        return (a, b)


## Execute a sequence of compare and switches. Lower number to the lower index
def cmp_seq(items: list, idx_pairs: list):
    items = copy.deepcopy(items)
    for ip in idx_pairs:
        (idx_lt, idx_gt) = cmp(ip[0], ip[1])    # Sort indexes
        items[idx_lt], items[idx_gt] = cmp(items[idx_lt], items[idx_gt])
    return items


## Shapes of compare indexes
shapes = [
            "nb",       # Negihbor
            # 0     x
            #       |
            # 1     x

            "py",       # Pyramid
            # 0     x
            # 1     | x
            #       | |
            # 2     | x
            # 3     x

            "cr"        # Cross
            # 0     x
            # 1     | x
            #       | |
            # 2     x |
            # 3       x
        ]


## Generate index pairs based on the input count and the comparison shape
def gen_idx_pairs(count: int, offset: int, shape: str):
    # Input check
    if count <= 1:
        raise Exception(f"Count must be higher than 1. Entered: {count}")
    if math.log2(count) != int(math.log2(count)):
        raise Exception(f"Count must be power of 2. Entered: {count}")
    if shape not in shapes:
        raise Exception(f"Shape must be in {shapes}. Entered: {shape}")

    # Generate pairs
    idx_pairs = []
    if shape == "nb":
        for i in range(int(count / 2)):
            ps = (offset + i * 2, offset + i * 2 + 1)
            idx_pairs.append(ps)

    elif shape == "py":
        for i in range(int(count / 2)):
            ps = (offset + i, offset + count - i - 1)
            idx_pairs.append(ps)

    elif shape == "cr":
        for i in range(int(count / 2)):
            ps = (offset + i, offset + i + int(count / 2))
            idx_pairs.append(ps)

    return idx_pairs


####################################################################################################
## Original Networks
####################################################################################################

# 2-input
NET_2 = gen_idx_pairs(2, 0, "nb")

# 4-input
NET_4 = gen_idx_pairs(4, 0, "nb")
NET_4 += gen_idx_pairs(4, 0, "py")
NET_4 += gen_idx_pairs(4, 0, "nb")

# 8-input
NET_8 = gen_idx_pairs(8, 0, "nb")

NET_8 += gen_idx_pairs(4, 0, "py")
NET_8 += gen_idx_pairs(4, 4, "py")
NET_8 += gen_idx_pairs(8, 0, "nb")

NET_8 += gen_idx_pairs(8, 0, "py")
NET_8 += gen_idx_pairs(4, 0, "cr")
NET_8 += gen_idx_pairs(4, 4, "cr")
NET_8 += gen_idx_pairs(8, 0, "nb")

# 16-input (takes too long)
NET_16 = gen_idx_pairs(16, 0, "nb")

for i in range(4):
    NET_16 += gen_idx_pairs(4, i * 4, "py")
NET_16 += gen_idx_pairs(16, 0, "nb")

for i in range(2):
    NET_16 += gen_idx_pairs(8, i * 8, "py")
for i in range(4):
    NET_16 += gen_idx_pairs(4, i * 4, "cr")
NET_16 += gen_idx_pairs(16, 0, "nb")

NET_16 += gen_idx_pairs(16, 0, "py")
for i in range(2):
    NET_16 += gen_idx_pairs(8, i * 8, "cr")
for i in range(4):
    NET_16 += gen_idx_pairs(4, i * 4, "cr")
NET_16 += gen_idx_pairs(16, 0, "nb")


####################################################################################################
## Check
####################################################################################################

## Check whether 2 lists have the same values
def check_items(ia: list, ib: list):
    for a, b in zip(ia, ib):
        if a != b:
            return False
    return True


## Check whether 2 networks has the same results
def check_nets(count: int, net_a: list, net_b: list):
    print(f"Input count: {count}")
    print(f"Network A: {net_a}")
    print(f"Network B: {net_b}")

    # Check all possible combinations
    eq = True
    pms = itertools.permutations(range(count))
    for pm in pms:
        items = list(pm)

        # Sort
        res_a = cmp_seq(items, net_a)
        res_b = cmp_seq(items, net_b)

        # Report failure
        if check_items(res_a, res_b) == False:
            eq = False
            print(f"\tPermutation {pm} failed.")
            print(f"\t\tResult A: {res_a}")
            print(f"\t\tResult B: {res_b}")

    if eq:
        print("The networks are equal\n")
    else:
        print("The networks are NOT equal\n")

    return eq

## Check whether a sorting network produce the same as the in-built sorting algorithm
def check_sort(count: int, net: list):
    print(f"Input count: {count}")
    print(f"Network: {net}")

    # Check all possible combinations
    eq = True
    pms = itertools.permutations(range(count))
    for pm in pms:
        items = list(pm)

        # Sort
        res = cmp_seq(items, net)
        items.sort()

        # Report failure
        if check_items(res, items) == False:
            eq = False
            print(f"\tPermutation {pm} failed.")
            print(f"\t\tResult:\t{res}")
            print(f"\t\tExpected:\t{items}")

    if eq:
        print("The networks is correct\n")
    else:
        print("The networks is NOT correct\n")

    return eq


####################################################################################################
## Test
####################################################################################################

## Test whether the original bitonic network can sort
def test_orig_net_sort(verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    eq = []
    eq.append(check_sort(2, NET_2))
    eq.append(check_sort(4, NET_4))
    eq.append(check_sort(8, NET_8))
    # eq.append(check_sort(16, NET_16))    # Takes too long

    sys.stdout = sys.__stdout__
    return not (False in eq)

## Test to confirm that the "Pyramid" shapes can be substituted with "Cross" shapes
def test_pynb_crnb_sub(verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    # 4-input, original & alternative network parts
    net_orig = gen_idx_pairs(4, 0, "py")
    net_orig += gen_idx_pairs(4, 0, "nb")

    net_alter = gen_idx_pairs(4, 0, "cr")
    net_alter += gen_idx_pairs(4, 0, "nb")

    eq = check_nets(4, net_orig, net_alter)

    sys.stdout = sys.__stdout__
    return eq


## Test whether py-nb and cr-py partial networks can be substituted
def test_pynb_crpy_sub_partial(verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    net_orig = gen_idx_pairs(4, 0, "py")
    net_orig += gen_idx_pairs(4, 0, "nb")

    net_alter = gen_idx_pairs(4, 0, "cr")
    net_alter += gen_idx_pairs(4, 0, "py")

    eq = check_nets(4, net_orig, net_alter)

    sys.stdout = sys.__stdout__
    return eq


## Test whether py-nb and cr-py can be substituted in a full network
def test_pynb_crpy_sub_full(verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    net_alter = gen_idx_pairs(4, 0, "nb")
    net_alter += gen_idx_pairs(4, 0, "cr")
    net_alter += gen_idx_pairs(4, 0, "py")

    eq = check_nets(4, NET_4, net_alter)

    sys.stdout = sys.__stdout__
    return eq


## Test whether it is possible to cut comparator from nb-cr-py
def test_nbcrpy_cut(verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    net_orig = gen_idx_pairs(4, 0, "nb")
    net_orig += gen_idx_pairs(4, 0, "cr")
    net_orig += gen_idx_pairs(4, 0, "py")

    net_alter = gen_idx_pairs(4, 0, "nb")
    net_alter += gen_idx_pairs(4, 0, "cr")
    net_alter += [(1, 2)]

    eq = check_nets(4, net_orig, net_alter)
    check_sort(4, net_alter)

    sys.stdout = sys.__stdout__
    return eq


####################################################################################################
## Main
####################################################################################################

if __name__ == "__main__":
    assert test_orig_net_sort() == True
    assert test_pynb_crnb_sub() == False
    assert test_pynb_crpy_sub_partial() == False
    assert test_pynb_crpy_sub_full() == True
    assert test_nbcrpy_cut(True) == True