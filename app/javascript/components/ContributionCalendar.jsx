import React, { useMemo } from 'react'
import { motion } from 'framer-motion'

const ContributionCalendar = ({ contributions, totalCount }) => {
    // Generate last 365 days
    const days = useMemo(() => {
        const arr = []
        const today = new Date()
        for (let i = 364; i >= 0; i--) {
            const d = new Date()
            d.setDate(today.getDate() - i)
            const dateStr = d.toISOString().split('T')[0]
            arr.push({
                date: dateStr,
                count: contributions[dateStr] || 0,
                dayOfWeek: d.getDay()
            })
        }
        return arr
    }, [contributions])

    // Group into weeks
    const weeks = useMemo(() => {
        const w = []
        let currentWeek = []

        // Pad the first week if necessary
        const firstDay = new Date(days[0].date).getDay()
        for (let i = 0; i < firstDay; i++) {
            currentWeek.push(null)
        }

        days.forEach(day => {
            currentWeek.push(day)
            if (currentWeek.length === 7) {
                w.push(currentWeek)
                currentWeek = []
            }
        })

        if (currentWeek.length > 0) {
            while (currentWeek.length < 7) {
                currentWeek.push(null)
            }
            w.push(currentWeek)
        }
        return w
    }, [days])

    const getColor = (count) => {
        if (count === 0) return 'var(--color-calendar-graph-day-bg)'
        if (count < 3) return 'var(--color-calendar-graph-day-L1-bg)'
        if (count < 6) return 'var(--color-calendar-graph-day-L2-bg)'
        if (count < 10) return 'var(--color-calendar-graph-day-L3-bg)'
        return 'var(--color-calendar-graph-day-L4-bg)'
    }

    return (
        <div className="contribution-calendar">
            <div className="calendar-header">
                {totalCount} contributions in the last year
            </div>

            <div className="calendar-graph">
                <div className="days-labels">
                    <span>Mon</span>
                    <span>Wed</span>
                    <span>Fri</span>
                </div>
                <div className="weeks-container">
                    {weeks.map((week, wi) => (
                        <div key={wi} className="calendar-week">
                            {week.map((day, di) => (
                                <motion.div
                                    key={di}
                                    className="calendar-day"
                                    style={{ backgroundColor: day ? getColor(day.count) : 'transparent' }}
                                    title={day ? `${day.count} contributions on ${day.date}` : ''}
                                    initial={{ scale: 0.8, opacity: 0 }}
                                    animate={{ scale: 1, opacity: 1 }}
                                    transition={{ delay: (wi * 0.01) + (di * 0.005) }}
                                />
                            ))}
                        </div>
                    ))}
                </div>
            </div>

            <div className="calendar-footer">
                <span>Less</span>
                <div className="legend">
                    <div className="calendar-day" style={{ backgroundColor: 'var(--color-calendar-graph-day-bg)' }}></div>
                    <div className="calendar-day" style={{ backgroundColor: 'var(--color-calendar-graph-day-L1-bg)' }}></div>
                    <div className="calendar-day" style={{ backgroundColor: 'var(--color-calendar-graph-day-L2-bg)' }}></div>
                    <div className="calendar-day" style={{ backgroundColor: 'var(--color-calendar-graph-day-L3-bg)' }}></div>
                    <div className="calendar-day" style={{ backgroundColor: 'var(--color-calendar-graph-day-L4-bg)' }}></div>
                </div>
                <span>More</span>
            </div>

            <style dangerouslySetInnerHTML={{
                __html: `
        :root {
          --color-calendar-graph-day-bg: #161b22;
          --color-calendar-graph-day-L1-bg: #0e4429;
          --color-calendar-graph-day-L2-bg: #006d32;
          --color-calendar-graph-day-L3-bg: #26a641;
          --color-calendar-graph-day-L4-bg: #39d353;
        }

        .contribution-calendar {
          border: 1px solid var(--border-color);
          border-radius: 6px;
          padding: 16px;
          margin-top: 24px;
          background: transparent;
        }

        .calendar-header {
          font-size: 0.9rem;
          color: var(--text-primary);
          margin-bottom: 12px;
        }

        .calendar-graph {
          display: flex;
          gap: 8px;
        }

        .days-labels {
          display: flex;
          flex-direction: column;
          justify-content: space-around;
          font-size: 0.7rem;
          color: var(--text-secondary);
          padding-top: 10px;
          padding-bottom: 15px;
        }

        .weeks-container {
          display: flex;
          gap: 3px;
          overflow-x: auto;
          padding-bottom: 8px;
        }

        .calendar-week {
          display: flex;
          flex-direction: column;
          gap: 3px;
        }

        .calendar-day {
          width: 10px;
          height: 10px;
          border-radius: 2px;
          flex-shrink: 0;
        }

        .calendar-footer {
          display: flex;
          align-items: center;
          justify-content: flex-end;
          gap: 4px;
          font-size: 0.7rem;
          color: var(--text-secondary);
          margin-top: 8px;
        }

        .legend {
          display: flex;
          gap: 3px;
          margin: 0 4px;
        }
      `}} />
        </div>
    )
}

export default ContributionCalendar
