// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// i3status is a port of the default i3status configuration to barista.
package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"barista.run"
	"barista.run/bar"
	"barista.run/base/click"
	"barista.run/colors"
	"barista.run/format"
	"barista.run/modules/battery"
	"barista.run/modules/clock"
	"barista.run/modules/diskspace"
	"barista.run/modules/funcs"
	"barista.run/modules/meminfo"
	"barista.run/modules/shell"
	"barista.run/modules/sysinfo"
	"barista.run/modules/wlan"
	"barista.run/outputs"
	"github.com/martinlindhe/unit"
)

type TogglReport struct {
	TotalGrand      int         `json:"total_grand"`
	TotalBillable   interface{} `json:"total_billable"`
	TotalCurrencies []struct {
		Currency interface{} `json:"currency"`
		Amount   interface{} `json:"amount"`
	} `json:"total_currencies"`
	Data []struct {
		Title struct {
			Client   interface{} `json:"client"`
			Project  interface{} `json:"project"`
			Color    string      `json:"color"`
			HexColor interface{} `json:"hex_color"`
		} `json:"title"`
		Pid     interface{}   `json:"pid"`
		Totals  []interface{} `json:"totals"`
		Details []struct {
			UID   int `json:"uid"`
			Title struct {
				User string `json:"user"`
			} `json:"title"`
			Totals []interface{} `json:"totals"`
		} `json:"details"`
	} `json:"data"`
	WeekTotals []interface{} `json:"week_totals"`
}

type Current struct {
	Data struct {
		ID          int       `json:"id"`
		GUID        string    `json:"guid"`
		Wid         int       `json:"wid"`
		Billable    bool      `json:"billable"`
		Start       time.Time `json:"start"`
		Duration    int       `json:"duration"`
		Description string    `json:"description"`
		Duronly     bool      `json:"duronly"`
		At          time.Time `json:"at"`
		UID         int       `json:"uid"`
	} `json:"data"`
}

func hourDelta(hours float64) float64 {
	weekday := int(time.Now().Weekday())
	target := 8

	delta := float64((weekday * target)) - hours

	return delta
}

func lastMonday() string {
	date := time.Now()

	monday := ""
	monday = date.Format("2006-01-02")

	for date.Weekday() != time.Monday {
		date = date.AddDate(0, 0, -1)
		monday = date.Format("2006-01-02")
	}
	return monday
}

func togglRequest(path string) ([]byte, error) {
	req, err := http.NewRequest("GET", path, nil)
	if err != nil {
		return []byte{}, err
	}
	req.SetBasicAuth(os.ExpandEnv("${TOGGL_KEY}"), "api_token")
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return []byte{}, err
	}
	defer resp.Body.Close()
	return bodyBytes, nil
}

func decimalToTime(hours float64) string {
	combined := fmt.Sprintf("%0.2f", hours)
	split := strings.Split(combined, ".")
	minutes, _ := strconv.Atoi(split[1])
	minutesConverted := float64(minutes) * 0.6

	return fmt.Sprintf("%v:%02d", split[0], int(minutesConverted))
}

func togglWeekly() (status string, running bool, err error) {
	report, err := togglRequest(fmt.Sprintf("https://toggl.com/reports/api/v2/weekly?user_agent=crazybus24@gmail.com&workspace_id=1525433&since=%s", lastMonday()))
	if err != nil {
		return
	}

	togglReport := TogglReport{}
	err = json.Unmarshal(report, &togglReport)
	if err != nil {
		return
	}

	total := float64(togglReport.TotalGrand) / float64(3600) / float64(1000)

	currentBody, err := togglRequest("https://toggl.com/api/v8/time_entries/current")
	if err != nil {
		return
	}

	current := Current{}
	err = json.Unmarshal(currentBody, &current)
	if err != nil {
		return
	}

	now := time.Now().Unix()
	currentSecs := current.Data.Start.Unix()
	currentHours := 0.0
	if currentSecs > 0 {
		running = true
		currentHours = float64(now-currentSecs) / 3600
	}

	allHours := total + currentHours

	delta := decimalToTime(hourDelta(allHours))

	hours := decimalToTime(allHours)

	return fmt.Sprintf("%s/%s", delta, hours), running, nil
}

func main() {
	colors.LoadFromMap(map[string]string{
		"good":     "#0f0",
		"bad":      "#f00",
		"degraded": "#ff0",
	})

	barista.Add(shell.New("/home/mick/bin/spotify_status.py").
		Every(time.Second * 10).
		Output(func(count string) bar.Output {
			return outputs.Textf("%s", count)
		}))

	barista.Add(shell.New("/home/mick/bin/gcal-next").
		Every(time.Minute * 10).
		Output(func(count string) bar.Output {

			agenda := strings.Split(count, " ")
			url := agenda[len(agenda)-1]
			return outputs.Textf("%s", count).OnClick(click.RunLeft("xdg-open", url))
		}))

	barista.Add(shell.New("/home/mick/bin/gcal-pagerduty").
		Every(time.Minute * 10).
		Output(func(count string) bar.Output {
			return outputs.Textf("%s", count).OnClick(click.RunLeft("xdg-open", "https://elastic.pagerduty.com/schedules#PBCOHVC"))
		}))

	barista.Add(funcs.Every(5*time.Minute, func(s bar.Sink) {
		output, running, err := togglWeekly()
		if err == nil {
			if running {
				s.Output(outputs.Text(output).Color(colors.Scheme("good")))
			} else {
				s.Output(outputs.Text(output).Color(colors.Scheme("bad")))
			}
		}
	}))

	barista.Add(diskspace.New("/").Output(func(i diskspace.Info) bar.Output {
		out := outputs.Text(format.IBytesize(i.Available))
		switch {
		case i.AvailFrac() < 0.2:
			out.Color(colors.Scheme("bad"))
		case i.AvailFrac() < 0.33:
			out.Color(colors.Scheme("degraded"))
		}
		return out
	}))

	barista.Add(wlan.Any().Output(func(w wlan.Info) bar.Output {
		switch {
		case w.Connected():
			out := fmt.Sprintf("%v:", w.SSID)
			if len(w.IPs) > 0 {
				out += fmt.Sprintf(" %s", w.IPs[0])
			}
			return outputs.Text(out).Color(colors.Scheme("good"))
		case w.Connecting():
			return outputs.Text("W: connecting...").Color(colors.Scheme("degraded"))
		case w.Enabled():
			return outputs.Text("W: down").Color(colors.Scheme("bad"))
		default:
			return nil
		}
	}))

	statusName := map[battery.Status]string{
		battery.Charging:    "CHR",
		battery.Discharging: "BAT",
		battery.NotCharging: "NOT",
		battery.Unknown:     "UNK",
	}
	barista.Add(battery.All().Output(func(b battery.Info) bar.Output {
		if b.Status == battery.Disconnected {
			return nil
		}
		if b.Status == battery.Full {
			return outputs.Text("FULL")
		}
		out := outputs.Textf("%s %d%% %s",
			statusName[b.Status],
			b.RemainingPct(),
			b.RemainingTime())
		if b.Discharging() {
			if b.RemainingPct() < 20 || b.RemainingTime() < 30*time.Minute {
				out.Color(colors.Scheme("bad"))
			}
		}
		return out
	}))

	barista.Add(sysinfo.New().Output(func(i sysinfo.Info) bar.Output {
		out := outputs.Textf("%.2f", i.Loads[0])
		if i.Loads[0] > 5.0 {
			out.Color(colors.Scheme("bad"))
		}
		return out
	}))

	barista.Add(meminfo.New().Output(func(i meminfo.Info) bar.Output {
		if i.Available() < unit.Gigabyte {
			return outputs.Textf(`MEMORY < %s`,
				format.IBytesize(i.Available())).
				Color(colors.Scheme("bad"))
		}
		out := outputs.Textf(format.IBytesize(i["MemTotal"] - i.Available()))
		switch {
		case i.AvailFrac() < 0.2:
			out.Color(colors.Scheme("bad"))
		case i.AvailFrac() < 0.33:
			out.Color(colors.Scheme("degraded"))
		}
		return out
	}))

	barista.Add(clock.Local().OutputFormat("2006-01-02 15:04:05"))

	panic(barista.Run())
}
