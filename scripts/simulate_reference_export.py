#!/usr/bin/env python3
"""Local simulation for the ABAP reference exporter design.

This does not execute ABAP. It validates the intended repository artifact shape,
manifest content, and publish-action assembly logic using representative sample
objects.
"""

from __future__ import annotations

import csv
import io
import json


def build_summary(obj):
    return "\n".join(
        [
            f"# {obj['obj_type']} {obj['obj_name']}",
            "",
            "## Purpose",
            "Reference snapshot exported from SAP for AI-assisted maintenance.",
            "",
            "## Confirmed metadata",
            f"- Package: `{obj['package']}`",
            f"- System: `{obj['system']}` Client `{obj['client']}`",
        ]
    )


def build_bundle(obj):
    root = f"objects/{obj['obj_type']}/{obj['obj_name']}"
    metadata = {
        "object_type": obj["obj_type"],
        "object_name": obj["obj_name"],
        "package": obj["package"],
        "system": obj["system"],
        "client": obj["client"],
    }
    files = []
    if obj["obj_type"] in {"CLAS", "INTF", "PROG"}:
      files.append((f"{root}/source.abap", "text/plain", obj["source"]))
    else:
      files.append((f"{root}/definition.txt", "text/plain", json.dumps(metadata)))
    files.append((f"{root}/metadata.json", "application/json", json.dumps(metadata)))
    files.append((f"{root}/summary.md", "text/markdown", build_summary(obj)))
    return files


def build_latest_refresh(profile, objects):
    return {
        "profile": profile["profile_id"],
        "package": profile["package_name"],
        "system": profile["system_folder"],
        "client": profile["client"],
        "object_count": len(objects),
    }


def build_object_index(objects):
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(["obj_type", "obj_name", "package", "system", "client"])
    for obj in objects:
        writer.writerow([obj["obj_type"], obj["obj_name"], obj["package"], obj["system"], obj["client"]])
    return out.getvalue()


def build_package_index(objects):
    counts = {}
    for obj in objects:
        counts[obj["package"]] = counts.get(obj["package"], 0) + 1
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(["package", "object_count", "system", "client"])
    for package, count in sorted(counts.items()):
        writer.writerow([package, count, objects[0]["system"], objects[0]["client"]])
    return out.getvalue()


def build_publish_actions(profile, objects):
    prefix = f"{profile['repository_root']}/systems/{profile['system_folder']}"
    actions = []
    for obj in objects:
        for path, content_type, content in build_bundle(obj):
            actions.append({"action": "upsert", "file_path": f"{prefix}/{path}", "content_type": content_type, "content": content})
    actions.append(
        {
            "action": "upsert",
            "file_path": f"{prefix}/manifests/latest-refresh.json",
            "content_type": "application/json",
            "content": json.dumps(build_latest_refresh(profile, objects)),
        }
    )
    actions.append(
        {
            "action": "upsert",
            "file_path": f"{prefix}/indexes/object-index.csv",
            "content_type": "text/csv",
            "content": build_object_index(objects),
        }
    )
    actions.append(
        {
            "action": "upsert",
            "file_path": f"{prefix}/indexes/package-index.csv",
            "content_type": "text/csv",
            "content": build_package_index(objects),
        }
    )
    return actions


def main():
    profile = {
        "profile_id": "DEFAULT",
        "package_name": "ZAI_REFERENCE",
        "repository_root": "reference",
        "system_folder": "DEV",
        "client": "100",
    }
    objects = [
        {
            "obj_type": "CLAS",
            "obj_name": "ZCL_SAMPLE_EXPORT",
            "package": "ZAI_REFERENCE",
            "system": "DEV",
            "client": "100",
            "source": "CLASS zcl_sample_export DEFINITION PUBLIC FINAL CREATE PUBLIC.",
        },
        {
            "obj_type": "DTEL",
            "obj_name": "ZREF_STATUS",
            "package": "ZAI_REFERENCE",
            "system": "DEV",
            "client": "100",
            "source": "",
        },
    ]

    latest_refresh = build_latest_refresh(profile, objects)
    actions = build_publish_actions(profile, objects)

    # Validate latest-refresh JSON serialization.
    latest_refresh_json = json.dumps(latest_refresh)
    json.loads(latest_refresh_json)

    print("Simulation passed")
    print(f"Objects: {len(objects)}")
    print(f"Publish actions: {len(actions)}")
    print("Sample files:")
    for action in actions[:5]:
        print(f"- {action['file_path']} [{action['content_type']}]")


if __name__ == "__main__":
    main()
