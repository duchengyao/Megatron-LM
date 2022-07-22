# lawrence mcafee

# ~~~~~~~~ import ~~~~~~~~
from collections import defaultdict
import time

from lutil import pax, print_rank

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Timer:

    def __init__(self):
        self.active_stack = []
        self.time_map = defaultdict(lambda : {"total": 0, "count": 0})

    def push(self, key):
        self.active_stack.append((key, time.time()))

    def pop(self):
        p = "/".join([ a[0] for a in self.active_stack ])
        k, t = self.active_stack.pop(-1)
        m = self.time_map[p]
        m["count"] += 1
        m["total"] += time.time() - t # 'time'
        m["single"] = m["total"] / m["count"]
        # print("timer | '%s' ... time %.3f, count %d." % (
        #     p,
        #     m["time"] / m["count"],
        #     m["count"],
        # ), flush = True)
        print_rank(0, "timer | '%s' ... [%d] single %.3f, total %.3f." % (
            p,
            m["count"],
            m["single"],
            m["total"],
        )) # , flush = True)

    def get_total_time(self):
        return sum(
            d["total"]
            for k, d in self.time_map.items()
            if len(k.split("/")) == 1
        )

    # def get_root_str(self):
    #     time_map = {
    #         # k : (d["time"] / d["count"])
    #         k : d["single"]
    #         for k, d in self.time_map.items()
    #         if len(k.split("/")) == 1
    #     }
    #     return "%.1f [ %s ]" % (
    #         sum(time_map.values()),
    #         ", ".join("%s %.1f" % (k, t) for k, t in time_map.items()),
    #     )
    def get_child_map(self, top_path):
        if top_path is None:
            return {
                p : d
                for p, d in self.time_map.items()
                if len(p.split("/")) == 1
        }
            
        top_len = len(top_path.split("/"))
        return {
            p.replace(top_path + "/", "") : d
            for p, d in self.time_map.items()
            if p.startswith(top_path) and len(p.split("/")) == top_len + 1
        }
    def get_child_str(self, top_path):
        child_map = self.get_child_map(top_path)
        # pax({
        #     "top_path" : top_path,
        #     "child_map" : child_map,
        # })
        return "%.1f [ %s ]" % (
            sum(d["total"] for d in child_map.values()),
            ", ".join("%s %.1f%s" % (k, d["total"], "" if d["count"] == 1 else "[/%d]" % d["count"]) for k, d in child_map.items()),
        )

    def print(self, depth = None):
        # >>>
        assert len(self.active_stack) == 0
        # <<<
        print("~~~~~~~~~~~~~~~~~~~~~", flush = True)
        # print("[ root = %s. ]" % self.get_root_str(), flush = True)
        max_klen = max(len(k) for k in self.time_map.keys())
        for k, d in self.time_map.items():
            klen = len(k.split("/"))
            if depth is not None and klen > depth:
                continue
            # print("%s ... time %.3f, count %d." % (
            #     k.ljust(max_klen), # 20),
            #     # d["time"] / d["count"],
            #     d["single"],
            #     d["count"],
            # ), flush = True)
            print("%s : %.3f%s." % (
                k.ljust(max_klen),
                d["total"],
                "" if d["count"] == 1 else " [ %d, %.3f ]" % (d["count"], d["single"]),
            ), flush = True)
        print("~~~~~~~~~~~~~~~~~~~~~", flush = True)
        # raise Exception("timer.")

# eof
