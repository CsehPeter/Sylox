
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
        self.cmps = []

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
        self.in_cnt = 2 ** degree
        self.net = []

    def __repr__(self):
        s = f"\tDegree: {self.degree}, Input count: {self.in_cnt}, Size: {self.get_size()}\n\t"
        for seg in self.net:
            s += repr(seg) + "\n\t"
        s = s[:-2]
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

    def remove_empty_stage(self):
        rm_lst = []
        for sgm in self.net:
            if len(sgm.cmps) == 0:
                rm_lst.append(sgm)
        for rm in rm_lst:
            self.net.remove(rm)

    def remove_duplicant(self):
        for i in range(1, len(self.net)):
            a_lst = self.net[i - 1].cmps
            b_lst = self.net[i].cmps

            rm_lst = []
            for a in a_lst:
                if a in b_lst:
                    rm_lst.append(a)
            for rm in rm_lst:
                b_lst.remove(rm)


    def trim(self, in_cnt):
        self.in_cnt = in_cnt
        self.degree = int(math.ceil(math.log2(in_cnt)))

        # Remove comparators
        for sgm in self.net:
            rm_lst = []
            for cmp in sgm.cmps:
                if cmp[0] >= in_cnt or cmp[1] >= in_cnt:
                    rm_lst.append(cmp)
            for rm in rm_lst:
                sgm.cmps.remove(rm)

        self.remove_empty_stage()
        self.remove_duplicant()
        self.remove_empty_stage()


####################################################################################################
## Specific Sorting Networks
####################################################################################################

class BatcherSortNet(SortNet):
    def __init__(self, degree):
        super().__init__(degree)
        self.gen_batcher(degree)

    def __repr__(self):
        return f"Batcher Sorting Network\n" + super().__repr__()

    def gen_batcher(self, degree: int):
        for d in range(degree):                         # Degree
            for s in range(d + 1):                      # Stage
                for g in range(2 ** (degree - d - 1)):  # Group
                    # Offset
                    offset = 2 ** (d + 1) * g       # Start index of the group
                    if s > 0:
                        offset += 2 ** (d - s)      # Start index of the comparator in the stage

                    # Count
                    if s == 0:
                        count = 1
                    else:
                        count = 2 ** s - 1

                    # Size
                    size = 2 ** (d - s)

                    # Add segment
                    seg = SortNetSegment(d, s, g)
                    seg.gen_cmps(offset, count, size, "cr")
                    self.net.append(seg)


class BitonicSortNet(SortNet):
    def __init__(self, degree):
        super().__init__(degree)
        self.gen_bitonic(degree)

    def __repr__(self):
        return f"Bitonic Sorting Network\n" + super().__repr__()

    def gen_bitonic(self, degree: int):
        for d in range(degree):                         # Degree
            for s in range(d + 1):                      # Stage
                for g in range(2 ** (degree - d - 1)):  # Group
                    # Offset
                    grp_offset = 2 ** (d + 1) * g       # Start index of the group
                    offset = grp_offset

                    # Count
                    count = 2 ** s

                    # Size
                    size = 2 ** (d - s)

                    # Shape
                    if s == 0:
                        shape = "py"
                    else:
                        shape = "cr"

                    # Add segment
                    seg = SortNetSegment(d, s, g)
                    seg.gen_cmps(offset, count, size, shape)
                    self.net.append(seg)


####################################################################################################
## Test
####################################################################################################

max_degree = 3
max_test_cnt = 10**3


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


def test_network(net_type: SortNet, verbose=False):
    if not verbose:
        sys.stdout = open(os.devnull, "w")

    ress = []
    for d in range(1, max_degree + 1):
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
    #res_bitonic = test_network(BitonicSortNet, False)
    res_batcher = test_network(BatcherSortNet, True)
    exit()

    net = BatcherSortNet(3)
    print(net)
    net.trim(3)
    print(net)