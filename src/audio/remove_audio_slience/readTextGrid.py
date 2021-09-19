import textgrid
import sys

def cut(input):
    tg = textgrid.TextGrid()
    tg.read(input)
    # print(tg.tiers[0].minTime, tg.tiers[0].maxTime)
    # nums = len(tg.tiers[0].intervals)
    intervals = tg.tiers[0].intervals
    start = tg.tiers[0].minTime
    end = tg.tiers[0].maxTime
    if intervals[0].mark == 'silence':
        start = intervals[0].bounds()[1]
    if intervals[-1].mark == 'silence':
        end = intervals[-1].bounds()[0]
    print(start, end)

    # for interval in tg.tiers[0].intervals:
    #     print(interval.bounds(), interval.mark)

if __name__ == '__main__':
    input_tg = sys.argv[1]
    cut(input_tg)