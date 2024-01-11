
import math, itertools, sys, os, random

####################################################################################################
## Sorting Network Comparator Segment
####################################################################################################

## Shapes of compare indexes
cmp_shapes = [
    "cr",        # Cross
    # 0     x
    # 1     | x
    #       | |
    # 2     x |
    # 3       x

    "py",       # Pyramid
    # 0     x
    # 1     | x
    #       | |
    # 2     | x
    # 3     x
]


class SortNetSegment():
    def __init__(self, deg_idx: int, stg_idx: int, grp_idx):
        # Input check
        if deg_idx < 0 or stg_idx < 0 or grp_idx < 0:
            raise Exception(f"All index must be GTE 0. \n\tGiven indexes: Degree: {deg_idx}, Stage: {stg_idx}, Group: {grp_idx}")

        # Assignment
        self.deg_idx = deg_idx
        self.stg_idx = stg_idx
        self.grp_idx = grp_idx

    def __repr__(self):
        return f"D: {self.deg_idx}, S: {self.stg_idx}, G: {self.grp_idx}, CMPS: {self.cmps}"


    def gen_cmps(self, offset: int, count: int, size: int, shape: str):
        # Input check
        if shape not in cmp_shapes:
            raise Exception(f"Shape must be in {cmp_shapes}. Given shape: {shape}")

        # Generate comparator index pairs
        cmps = []
        for i in range(count):
            for j in range(size):
                idx_low = offset + i * 2 * size + j

                if shape == "cr":
                    idx_high = idx_low + size
                elif shape == "py":
                    idx_high = idx_low + 2 * (size - j) -  1

                cmps.append((idx_low, idx_high))

        self.cmps = cmps


####################################################################################################
## Sorting Network (General)
####################################################################################################

class SortNet():
    def __init__(self, degree: int):
        self.degree = degree
        self.net = []

    def __repr__(self):
        s = "\t"
        for seg in self.net:
            s += repr(seg) + "\n\t"
        s = s[:-4]
        return s


    # Add a list of index pairs with the specified degree, stage, group
    def add_seg(self, segment: SortNetSegment):
        self.net += segment

    def compare(self, a: int, b: int):
        if a > b:
            return (b, a)
        else:
            return (a, b)

    def sort(self, vals: list):
        for seg in self.net:
            for cmp in seg.cmps:
                vals[cmp[0]], vals[cmp[1]] = self.compare(vals[cmp[0]], vals[cmp[1]])

    def get_size(self):
        s = 0
        for seg in self.net:
            s += len(seg.cmps)
        return s

####################################################################################################
## Specific Sorting Networks
####################################################################################################

class BatcherSortNet(SortNet):
    def __init__(self, degree):
        super().__init__(degree)
        self.gen_batcher(degree)

    def __repr__(self):
        return f"Batcher Sorting Network\n\tDegree: {self.degree}, Size: {self.get_size()}\n" + super().__repr__()

    def gen_batcher(self, degree: int):
        for d in range(degree):                         # Degree
            for s in range(d + 1):                      # Stage
                for g in range(2 ** (degree - d - 1)):  # Group
                    # Offset
                    grp_offset = offset = 2 ** (d + 1) * g      # Starting index of the group
                    cmp_offset = 2 ** (d - s)                   # Starting index of the comparator in the stage
                    if s == 0:
                        offset = grp_offset
                    else:
                        offset = grp_offset + cmp_offset

                    # Count
                    if s == 0:
                        cnt = 1
                    else:
                        cnt = 2 ** s - 1

                    # Size
                    size = 2 ** (d - s)

                    # Add segment
                    seg = SortNetSegment(d, s, g)
                    seg.gen_cmps(offset, cnt, size, "cr")
                    self.net.append(seg)


class BitonicSortNet(SortNet):
    def __init__(self, degree):
        super().__init__(degree)
        self.gen_bitonic(degree)

    def __repr__(self):
        return f"Bitonic Sorting Network\n\tDegree: {self.degree}, Size: {self.get_size()}\n" + super().__repr__()

    def gen_bitonic(self, degree: int):
        for d in range(degree):                         # Degree
            for s in range(d + 1):                      # Stage
                for g in range(2 ** (degree - d - 1)):  # Group
                    # Offset
                    grp_offset = offset = 2 ** (d + 1) * g      # Starting index of the group
                    offset = grp_offset

                    # Count
                    cnt = 2 ** s

                    # Size
                    size = 2 ** (d - s)

                    # Shape
                    if s == 0:
                        shape = "py"
                    else:
                        shape = "cr"

                    # Add segment
                    seg = SortNetSegment(d, s, g)
                    seg.gen_cmps(offset, cnt, size, shape)
                    self.net.append(seg)


####################################################################################################
## Test
####################################################################################################

max_degree = 4
max_test_cnt = 10**5

def gen_test_cases(degree: int):
    test_cnt = math.factorial(2 ** degree)
    if test_cnt < max_test_cnt:
        test_cases = list(itertools.permutations(range(2 ** degree)))
    else:
        test_cases = []
        for i in range(max_test_cnt):
            test_cases.append(random.sample(range(2 ** degree), 2 ** degree))

    return test_cases


def check_sort(vals: list):
    for i in range(1, len(vals)):
        if vals[i - 1] > vals[i]:
            return False
    return True



## Test whether the original bitonic network can sort
def test_network(net_type: SortNet, verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    ress = []
    for d in range(1, max_degree):
        net = net_type(d)
        tests = gen_test_cases(d)

        print(f"Testing in {len(tests)} test cases...")
        print(net)

        res = True
        for t in tests:
            t = list(t)
            s = repr(t)
            net.sort(t)
            if check_sort(t) == False:
                print(f"Sorting failed at: {s}")
                res = False
        if res:
            print("...passed\n")
        ress.append(res)

    sys.stdout = sys.__stdout__
    return ress


####################################################################################################
## Main
####################################################################################################

if __name__ == "__main__":
    print(test_network(BitonicSortNet, False))
    print(test_network(BatcherSortNet, True))