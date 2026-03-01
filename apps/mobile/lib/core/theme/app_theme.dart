import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // User defined custom colors made with FlexSchemeColor() API.
    colors: const FlexSchemeColor(
      primary: Color(0xFF084049),
      primaryContainer: Color(0xFF2A676F),
      secondary: Color(0xFFE8A028),
      secondaryContainer: Color(0xFFF6D9AA),
      tertiary: Color(0xFF5E5B7D),
      tertiaryContainer: Color(0xFFE4DFFF),
      appBarColor: Color(0xFFF6D9AA),
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
    ),
    // Surface color adjustments.
    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    blendLevel: 4,
    lightIsWhite: true,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnLevel: 10,
      useM2StyleDividerInM3: true,
      defaultRadius: 12.0,
      textButtonRadius: 25.0,
      filledButtonRadius: 25.0,
      outlinedButtonRadius: 25.0,
      outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      outlinedButtonPressedBorderWidth: 2.0,
      toggleButtonsBorderSchemeColor: SchemeColor.primary,
      segmentedButtonSchemeColor: SchemeColor.primary,
      segmentedButtonBorderSchemeColor: SchemeColor.primary,
      switchSchemeColor: SchemeColor.primary,
      switchThumbSchemeColor: SchemeColor.primaryFixedDim,
      checkboxSchemeColor: SchemeColor.secondary,
      radioSchemeColor: SchemeColor.secondary,
      unselectedToggleIsColored: true,
      sliderValueTinted: true,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBackgroundAlpha: 21,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 12.0,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      fabUseShape: true,
      fabAlwaysCircular: true,
      popupMenuRadius: 6.0,
      popupMenuElevation: 8.0,
      alignedDropdown: true,
      drawerIndicatorSchemeColor: SchemeColor.primary,
      bottomNavigationBarMutedUnselectedLabel: false,
      bottomNavigationBarMutedUnselectedIcon: false,
      menuRadius: 6.0,
      menuElevation: 8.0,
      menuBarRadius: 0.0,
      menuBarElevation: 1.0,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
      navigationRailUseIndicator: true,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailIndicatorOpacity: 1.00,
    ),
    // ColorScheme seed generation configuration for light mode.
    keyColors: const FlexKeyColors(
      useSecondary: true,
      keepPrimary: true,
      keepSecondary: true,
      keepTertiary: true,
      keepPrimaryContainer: true,
      keepSecondaryContainer: true,
      keepTertiaryContainer: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

}
