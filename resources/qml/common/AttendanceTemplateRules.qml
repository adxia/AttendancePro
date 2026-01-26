pragma Singleton
import QtQuick

QtObject {
    readonly property var baseRules: ([
        { key: "modelName", label: "模板名称", required: true },
        { key: "inputType", label: "输入表类型", required: true },
        { key: "inputSheetName", label: "Sheet 名称", required: true },
        { key: "inputuserColumn", label: "姓名列号", required: true, type: "column" },
        { key: "formalSheetName", label: "正式工 Sheet 名称", required: true },
        { key: "formalStartRow", label: "正式工起始行", required: true, type: "row" },
        { key: "formalStartColumn", label: "正式工起始列", required: true, type: "column" },
        { key: "formalNameColumn", label: "正式工姓名列", required: true, type: "column" },
        { key: "formalDateRow", label: "正式工日期行", required: true, type: "row" },
        { key: "formalDateFormat", label: "正式工日期格式", required: true },

        { key: "serviceSheetName", label: "劳务工 Sheet 名称", required: true },
        { key: "serviceStartRow", label: "劳务工起始行", required: true, type: "row" },
        { key: "serviceStartColumn", label: "劳务工起始列", required: true, type: "column" },
        { key: "serviceNameColumn", label: "劳务工姓名列", required: true, type: "column" },
        { key: "serviceDateRow", label: "劳务工日期行", required: true, type: "row" },
        { key: "serviceDateFormat", label: "劳务工日期格式", required: true }
    ])


    readonly property var inputTypeRules: ({
        "CheckInLog": [
               { key: "inputdateColumn", label: "日期列号", required: false, type: "column" },
               { key: "attendanceTime", label: "考勤时间列号", required: true, type: "column" },
        ],

        "AttendanceSummary": [
               { key: "inputdateColumn", label: "日期列号", required: true, type: "column" },
               { key: "signInColumn", label: "签到时间列号", required: true, type: "column" },
               { key: "signOutColumn", label: "签退时间列号", required: true, type: "column" },
        ]
    })


    // --- 主校验函数 ---
    function validate(form) {
        if (!form) return error("数据未初始化")

        // 第一步：校验基础规则
        var baseResult = _validateRules(form, baseRules)
        if (!baseResult.ok) return baseResult

        // 第二步：获取 inputType 并校验特定规则
        var type = form["inputType"]
        if (type && inputTypeRules[type]) {
            var specificRules = inputTypeRules[type]
            var specificResult = _validateRules(form, specificRules)
            if (!specificResult.ok) return specificResult
        }

        return { ok: true }
    }

    // --- 内部通用校验逻辑 (避免代码重复) ---
    function _validateRules(form, rules) {
        for (var i = 0; i < rules.length; i++) {
            var rule = rules[i]
            var value = form[rule.key]

            // 必填校验
            if (rule.required) {
                if (value === undefined || value === null || value === "") {
                    return error(rule.label + " 不能为空")
                }
            }

            // 格式校验 (仅当有值时校验)
            if (rule.type && value !== undefined && value !== null && value !== "") {
                var result = validateType(value, rule.type)
                if (!result.ok) {
                    return error(rule.label + " " + result.message)
                }
            }
        }
        return { ok: true }
    }

    function validateType(value, type) {
        switch (type) {
        case "column":
            if (!/^[A-Z]+$/i.test(value))
                return { ok: false, message: "格式应为 Excel 列号（如 A / AA）" }
            break

        case "row":
            if (!/^[1-9]\d*$/.test(value))
                return { ok: false, message: "应为大于 0 的整数" }
            break
        }

        return { ok: true }
    }

    function error(msg) {
        return { ok: false, message: msg }
    }

}
