
import subprocess
import json



def get_updates():
    try:
        output = subprocess.check_output(
            ['checkupdates'], stderr=subprocess.STDOUT , text=True
        )
        count = len(output.strip().split('\n')) if output.strip() else 0
        return count

    except FileNotFoundError:
        return -1
    except subprocess.CalledProcessError:
        return 0


def main():
    update_count = get_updates()

    if update_count > 0:
        text = f"{update_count} updates"
        tooltip = "updates are available"
        css_class = "updates-available"
    elif update_count == 0:
        text = "Up to date"
        tooltip = "System is up to date"
        css_class = "no-updates"
    else:
        text = "Error"
        tooltip = "Could not check for updates"
        css_class = "error"


    output_json = {
        "text": text,
        "tooltip": tooltip,
        "class": css_class,
    }
    print(json.dumps(output_json))





if __name__ == "__main__":
    main()
