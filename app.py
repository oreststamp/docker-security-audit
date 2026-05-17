import subprocess
import json
from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    results = None
    image_name = ""
    error = None

    if request.method == "POST":
        image_name = request.form.get("image_name", "").strip()
        if image_name:
            try:
                # Run Trivy scan, output as JSON
                result = subprocess.run(
                    ["trivy", "image", "--format", "json",
                     "--severity", "HIGH,CRITICAL", image_name],
                    capture_output=True, text=True, timeout=120
                )
                data = json.loads(result.stdout)
                results = []
                for target in data.get("Results", []):
                    for vuln in target.get("Vulnerabilities", []):
                        results.append({
                            "id": vuln.get("VulnerabilityID"),
                            "pkg": vuln.get("PkgName"),
                            "severity": vuln.get("Severity"),
                            "installed": vuln.get("InstalledVersion"),
                            "fixed": vuln.get("FixedVersion", "No fix yet"),
                            "title": vuln.get("Title", "")
                        })
            except Exception as e:
                error = str(e)

    return render_template("index.html",
                           results=results,
                           image_name=image_name,
                           error=error)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
