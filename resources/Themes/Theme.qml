pragma Singleton
import QtQuick
import QtQuick.Window


QtObject {
    id: theme
    property int changetime:100
    property int xchangetime:100
    property int sliderwidth:200
    property int impliwidth:200
    property var lightTheme:{
        // 主色
        'primaryColor': '#5C67FA',
        'primaryLight': '#8b5cf6',
        'primaryDark': '#4f46e5',
        'dropshodow':'#805C67FA',
        'tableshodow':'#1A000000',
        'comboboxshadow':'#f3f4f6',
        'editback':'#1A5C67FA',
        "Toast":'#1A5C67FA',
        'fileinput':"#F9FAFB",
        'circal':'f8f8f8',
        'panelcolor':'#Ffffff',
        // 文字颜色
        'textPrimary': '#232946',
        'textSecondary': '#6b7280',
        'textTertiary': '#b0b3c2',
        'menuPrimary': '#5C67FA',
        'footprimary': '#5C67FA',
        'scrollbar':'#b2b2b2',

        // 背景色（Dark 偏黑，不偏蓝）
        'backgroundPrimary': '#ffffff',
        'searchbackground': '#f1f1f1',
        'tabletitle': '#f1f4f6',
        'changebackground':"#ffffff",
        // 'backgroundSecondary': '#f2f4f7',
          'backgroundSecondary': '#f9fafb',
        // 'titlebackground': '#f8fafb',
        'titlebackground': 'transparent',
        'backgroundGradientStart': '#e5e5e5',
        'backgroundGradientEnd': '#e5e7eb',
        'menubackground': '#0D5C67FA',
        // 'contentbackground': '#f9fafb',
        'contentbackground': '#f8fafb',
        'buttonback': '#F9FAFB',
        'footback': '#fefefe',
        'itembackground': '#fefefe',

        // 边框
        'borderLight': '#f2f2f2',
        'borderHover': 'transparent',

        // 卡片
        'cardIconBackground': '#f5f3ff',
        'cardHoverBorder': '#8b5cf6',

        // 按钮渐变
        'buttonGradientStart': '#8b5cf6',
        'buttonGradientEnd': '#6366f1',
        'buttonGradientHoverStart': '#7c3aed',
        'buttonGradientHoverEnd': '#4f46e5',

        // 状态颜色
        'statusError': '#ef4444',
        'statusSuccess': '#10b981',
        'statusWarning': '#f59e0b',
        'statusInfo': '#3b82f6',

        // 透明
        'transparent': 'transparent',
        'semiTransparentWhite': '#80ffffff',
    }

    property var darkTheme:{
        // 主色
        'primaryColor': Qt.lighter('#5C67FA',1.05),
        'primaryLight': '#6366f1',
        'primaryDark': '#3730a3',
        'panelcolor':'#1E1E1E',
        // 文字颜色
        "Toast":'#242424',
        'textPrimary': '#f5f5f5',
        'textSecondary': '#d1d5db',
        'textTertiary': '#a1a1aa',
        'menuPrimary': '#f5f5f5',
        'footprimary': '#f5f5f5',
        'scrollbar':'#777777',
        'dropshodow':'#0D444444',
        'tableshodow':'#1f1f1f',
        'comboboxshadow':'#090909',
        'fileinput':"#090909",
        'editback':'#335C67FA',
        'circal':'#444444',

        // 背景色（Dark 偏黑，不偏蓝）
        'backgroundPrimary': '#242424',
        'searchbackground': '#202020',
        'changebackground':"#020202",
        'tabletitle': '#2e2e2e',
        'backgroundSecondary': '#2e2e2e',
        // 'titlebackground': '#1e1e1e',
        'titlebackground': 'transparent',
        'backgroundGradientStart': '#2c2c2c',
        'backgroundGradientEnd': '#2a2a2a',
        'menubackground': '#1Affffff',
        'contentbackground': '#1e1e1e',
        'footback': '#161616',
        'buttonback': '#1e1e1e',
        'itembackground':'#313131',


        // 边框
        'borderLight': 'transparent',
        'borderHover': 'transparent',

        // 卡片
        'cardIconBackground': '#2a2a2a',
        'cardHoverBorder': '#8b5cf6',

        // 按钮渐变
        'buttonGradientStart': '#4f46e5',
        'buttonGradientEnd': '#4338ca',
        'buttonGradientHoverStart': '#3730a3',
        'buttonGradientHoverEnd': '#312e81',

        // 状态颜色
        'statusError': '#ef4444',
        'statusSuccess': '#10b981',
        'statusWarning': '#f59e0b',
        'statusInfo': '#3b82f6',

        // 透明
        'transparent': 'transparent',
        'semiTransparentWhite': '#40ffffff',

    }
    property var darkmica:{
        // 主色
        'primaryColor': '#4f46e5',
        'primaryLight': '#6366f1',
        'primaryDark': '#3730a3',

        // 文字颜色
        'textPrimary': '#f5f5f5',
        'textSecondary': '#b1b5b',
        'textTertiary': '#a1a1aa',
        'menuPrimary': '#f5f5f5',
        'footprimary': '#f5f5f5',
        'scrollbar':'#d2d2d2',
        'dropshodow':'#1A5C67FA',

        'backgroundPrimary': 'transparent',
        'backgroundSecondary': 'transparent',
        'titlebackground': 'transparent',
        'backgroundGradientStart': 'transparent',
        'backgroundGradientEnd': 'transparent',
        'menubackground': '#1AAAAAAA',
        'contentbackground': '#1e1e1e',
        'itembackground': '#1AAAAAAA',
        'footback': '#1A222222',

        // 边框
        'borderLight': 'transparent',
        'borderHover': 'transparent',

        // 卡片
        'cardIconBackground': '#2a2a2a',
        'cardHoverBorder': '#8b5cf6',

        // 按钮渐变
        'buttonGradientStart': '#4f46e5',
        'buttonGradientEnd': '#4338ca',
        'buttonGradientHoverStart': '#3730a3',
        'buttonGradientHoverEnd': '#312e81',

        // 状态颜色
        'statusError': '#ef4444',
        'statusSuccess': '#10b981',
        'statusWarning': '#f59e0b',
        'statusInfo': '#3b82f6',

        // 透明
        'transparent': 'transparent',
        'semiTransparentWhite': '#40ffffff',
    }

        property var lightmica:{
                'primaryColor': '#5C67FA',
                'primaryLight': '#8b5cf6',
                'primaryDark': '#4f46e5',

                // 文字颜色
                'textPrimary': '#232946',
                'textSecondary': '#6b7280',
                'textTertiary': '#b0b3c2',
                'menuPrimary': '#f5f5f5',
                'footprimary': '#5C67FA',
                'scrollbar':'#d2d2d2',
                'dropshodow':'#4D5C67FA',

                // 背景色（Dark 偏黑，不偏蓝）
                'backgroundPrimary': 'transparent',
                'backgroundSecondary': '#ffffff',
                'titlebackground': 'transparent',
                'backgroundGradientStart': 'transparent',
                'backgroundGradientEnd': 'transparent',
                'menubackground': '#1AAAAAAA',
                'itembackground': '#1AAAAAAA',
                'contentbackground': '#f2f4f7',
                'footback': '#1A222222',

                // 边框
                'borderLight': 'transparent',
                'borderHover': 'transparent',

                // 卡片
                'cardIconBackground': '#f5f3ff',
                'cardHoverBorder': '#8b5cf6',

                // 按钮渐变
                'buttonGradientStart': '#8b5cf6',
                'buttonGradientEnd': '#6366f1',
                'buttonGradientHoverStart': '#7c3aed',
                'buttonGradientHoverEnd': '#4f46e5',

                // 状态颜色
                'statusError': '#ef4444',
                'statusSuccess': '#10b981',
                'statusWarning': '#f59e0b',
                'statusInfo': '#3b82f6',

                // 透明
                'transparent': 'transparent',
                'semiTransparentWhite': '#80ffffff',
        }
}

