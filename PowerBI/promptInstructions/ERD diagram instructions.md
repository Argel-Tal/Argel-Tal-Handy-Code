# Entity Relationship Diagram (ERD) Generation Instructions

## Purpose
As Power BI Developer, it is important for me to understand the semantic model relationships and how different tables are connected through different types and directions of relations.

This document provides step-by-step instructions for generating a professional Entity Relationship Diagram (ERD) for Power BI semantic models, following best practices for table relationships, cardinality, and visual hierarchy.

## Prerequisites
- Access to the Power BI semantic model's `model.bim` file
- Draw.io or compatible diagram editor (web: draw.io, desktop, or VS Code extensions)
- Understanding of the semantic model structure (fact tables, dimensions, mappings)

## Tips & Best Practices

1. **Consistency**: Keep all dimension tables at similar visual height for readability
0. **Spacing**: Leave adequate space between tables to prevent connector line overlap
0. **Column Ordering**: Put PK/FKs first, then related columns, then other columns
0. **Naming**: Use the names for columns from the model, include direction indicators in FK values in brackets after the FK name
0. **Documentation**: Add inline comments to model.bim explaining complex relationships

## Step 1: Extract Model Information

### 1.1 Identify Tables
From the `model.bim` file, locate all enabled table definitions under the `"tables"` array. 
Exclude any tables which are disabled for load, such as those in the Expressions section. These typically represent staging tables, and don't need to be added to final model ERDs.

**Semantic Model Name:** `<!-- PLACEHOLDER: SEMANTIC_MODEL_NAME -->`

Extract the following information for each table:
- Table name
- All columns with data types
- Table role (Fact, Dimension, or Mapping)

### 1.2 Identify Relationships
From the `"relationships"` array in the model.bim file, extract:
- Relationship name
- From table name and column (foreign key)
- To table name and column (primary key)
- Cross filtering mode: `crossFilteringBehavior` _(apply filtering in both or single direction)_
- Cardinality: `fromCardinality` one/many and implicit `toCardinality`
- Activity: if the Relationship is `Active` (driving filtering) or `Inactive` (potentially used in specific Measures)

### 1.3 Categorize Tables

**Fact Tables** (typically purple/lavender):
- Central transactional tables, with unique record identifiers and high cardinality
- Example: `usage_fact` in `<!-- PLACEHOLDER: SEMANTIC_MODEL_NAME -->`

**Dimension Tables** (typically green):
- Lookup/reference tables, with categories & grouping factors. 
_These might be standalone tables with categories that are mapped into columns of Fact Tables, or might be tables with repeating elements which are unique identifiers from Fact Tables where many values are supported for a specific metadata type, i.e. 1x `record` many have many `tags`_
- Example: `record_tags`, `record_meta` in `<!-- PLACEHOLDER: SEMANTIC_MODEL_NAME -->`

**Bridging / Mapping Tables** (typically light-grey):
- Used to resolve many-to-many relationships into 2+ one-to-many relationships, breaking down complex associations into manageable, efficient, and normalized database structures
- Example: User Roles: A User has many Roles, a Role has many Users (Bridge: UserRoles)

**Reference Tables** (typically yellow):
- Lookup tables with limited columns. 
_These are mostly used to abstract categories into user-friendly names, or to bridge tables which have different names in different systems_
- Example: `mapping_environment`, `mapping_job_status` in `<!-- PLACEHOLDER: SEMANTIC_MODEL_NAME -->`

**Date / Calendar Tables** (typically light-green):
- A special type of Dimension Table which contains 1 row for each date within a range. 
_Typically this has columns for different time/date groupings, such as if a date is a weekend, which month it occurs in, what the start of the corresponding week was, ..._
- This table often has many relationships between this table's primary key [`Date`] column, and columns in fact tables, or other dimension tables. 
_This is especially true for Silver & Gold medallion tables where event data has been reshaped to reflect an abstracted view of entities. i.e. record level tables which map "studentID, classID, enrollmentDate, CompletionDate" is brought into an abstracted "student record" containing "student commencement date, class 1 start, class 1 finish, class 2 start, ... program completion date, graduation date"._

**Measures Tables**: (typically red):
- A PowerBI specific concept, where counting rules called "Measures" are stored, allowing them to be quickly identified and referenced by Developers

## Step 2: Design the Diagram Layout

### 2.1 Position Strategy

**Grouping 1: Model view**: This grouping shows the logical relationships between entities, but excludes the Date / Calendar table to reduce visual noise.

- **Top Left**: Measures table - kept out the way of the relationship diagrams
- **Center**: Fact table (largest, most connections)
- **Top**: Dimension tables connected to fact table (excluding the Date Dimension Table)
- **Right**: Secondary dimension tables or more specific dimensions
- **Bottom**: Mapping/lookup tables

**Grouping 2: Calendar view**: This grouping explicitly focuses on any date-based relationships. It will always include the Date Dimension table, may include both Fact and Dimension tables. 

This grouping should be placed to the far-right of "Grouping 1", such that it doesn't overlap. Putting it on the same page ensures it's always visible, regardless of rendering engine.

- **Center**: Date Dimension table (largest, most connections)
- **Right**: Fact Table
- **Around the centre**: Related Dimension tables which have a datetime component 

### 2.2 Canvas Configuration
```xml
<!-- Ensure proper viewport settings for visibility -->
<mxGraphModel dx="3000" dy="2000" grid="1" gridSize="10" 
              fold="0" page="0" 
              pageWidth="2400" pageHeight="2400" 
              background="#ffffff">
```

**Key settings:**
- `fold="0"` - Disable page breaks (show all on one canvas)
- `page="0"` - Infinite canvas mode
- `dx/dy` - Viewport size (increase for large models)
- `pageWidth/pageHeight` - Canvas size

## Step 3: Create Table Visual Elements

### 3.1 Table Container Structure
Each table is a swimlane with individual cells for each column:

```xml
<mxCell id="TABLE_NAME" value="table_name" 
        style="swimlane;fontStyle=1;align=center;verticalAlign=top;
        swimlaneFillColor=#COLOR;startSize=30;html=1;rounded=1;shadow=1;strokeWidth=2;" 
        parent="1" vertex="1">
  <mxGeometry x="X_POSITION" y="Y_POSITION" width="WIDTH" height="HEIGHT" as="geometry" />
</mxCell>
```

**Color recommendations:**
- Fact tables: `#e1d5e7` (purple)
- Dimension tables: `#d5e8d4` (green)
- Mapping tables: `#fff2cc` (light-grey)
- Date Dimension table: `#fff2cc` (light-grey)
- Reference: `#BA8E23` (yellow)
- Measure tables: `#ffe6e6` (red)


### 3.2 Primary Key Row (First Row)
```xml
<mxCell id="TABLE_pk" value="🔑 column_name (PK)" 
        style="text;align=left;verticalAlign=middle;spacingLeft=8;
        fontStyle=1;fontSize=10;fontColor=#0000AA;strokeColor=#0000AA;strokeWidth=2;" 
        parent="TABLE_NAME" vertex="1">
  <mxGeometry y="30" width="280" height="26" as="geometry" />
</mxCell>
```

**Key styling:**
- `fontColor=#0000AA` (blue for PK)
- `strokeWidth=2` (bold highlight)
- Icon: `🔑`

### 3.3 Foreign Key Rows
```xml
<mxCell id="TABLE_fk_name" value="🔑 column_name (FK→TargetTable)" 
        style="text;align=left;verticalAlign=middle;spacingLeft=8;
        fontStyle=1;fontSize=9;fontColor=#AA0000;" 
        parent="TABLE_NAME" vertex="1">
  <mxGeometry y="POSITION" width="280" height="24" as="geometry" />
</mxCell>
```

**Key styling:**
- `fontColor=#AA0000` (red for FK)
- Include target table name in value
- Icon: `🔑`

### 3.4 Regular Column Rows
```xml
<mxCell id="TABLE_c1" value="column_name" 
        style="text;align=left;verticalAlign=middle;spacingLeft=8;
        overflow=hidden;rotatable=0;fontSize=9;" 
        parent="TABLE_NAME" vertex="1">
  <mxGeometry y="Y_POSITION" width="280" height="24" as="geometry" />
</mxCell>
```

### 3.5 Divider Line Between PK/FK and Regular Columns
```xml
<mxCell id="TABLE_divider" value="" style="line;html=1;strokeWidth=1;" 
        parent="TABLE_NAME" vertex="1">
  <mxGeometry y="POSITION" width="280" height="1" as="geometry" />
</mxCell>
```

## Step 4: Create Relationship Connectors

### 4.1 Relationship Edge Structure
```xml
<mxCell id="relN" 
        style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;
        html=1;endArrow=ERmandOne;startArrow=ERmandOne;strokeWidth=2;
        strokeColor=#0000CC;" 
        parent="1" source="SOURCE_FK_CELL" target="TARGET_PK_CELL" edge="1">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="X1" y="Y1" />
      <mxPoint x="X2" y="Y2" />
    </Array>
  </mxGeometry>
</mxCell>
```

**Text annotation**: Make the relationship label a text element attached to the line, and set it to have a default colour fill background so the text is visible where lines go behind the text. Default fill ensures it works with both light and dark mode.

**Cardinality arrows (Chen ERD notation):**
- `startArrow=ERone;endArrow=ERone` - One-to-One (line on both ends)
- `startArrow=ERmany;endArrow=ERone` - Many-to-One (crow's foot on start, line on end)
- `startArrow=ERone;endArrow=ERmany` - One-to-Many (line on start, crow's foot on end)
- `startArrow=ERmany;endArrow=ERmany` - Many-to-Many (crow's foot on both)

**For semantic models:**
In a typical star schema, all fact-dimension relationships are Many:One:
- Many rows in the fact table → One row in the dimension
- Use: `startArrow=ERmany;endArrow=ERone` (crow's foot at FK side, line at PK side)

**Line styling:**
- **Bidirectional**: Solid line (`strokeColor=#0000CC`, blue)
- **Single direction**: `dashed=1` with `strokeColor=#FF6600` (orange)

**Line connections**: Start and End the line from the left/right side of the table row's representing PK/FK columns, so the lines go out sideways, not overtop tables. 

### 4.2 Relationship Labels
```xml
<mxCell id="relN_label" 
        value="Cardinality&#10;column_source = column_target" 
        style="text;align=center;verticalAlign=middle;fontSize=8;" 
        parent="1" vertex="1">
  <mxGeometry x="X" y="Y" width="80" height="40" as="geometry" />
</mxCell>
```

## Step 5: Add Legend

### 5.1 Legend Best Practices

Legend Title cell:
```xml
<mxCell id="legend_title" value="LEGEND" 
        style="text;fontStyle=1;fontSize=12;align=left;verticalAlign=middle;spacingLeft=10;" 
        parent="1" vertex="1">
  <mxGeometry x="50" y="1350" width="500" height="25" as="geometry" />
</mxCell>
```

- 🔑 PK (Primary Key) = Unique identifier 
- 🔑 FK (Foreign Key) = Reference" 

XML style reference: ="text;fontSize=9;align=left;verticalAlign=top;spacingLeft=10;"parent="1" vertex="1"

### 5.2 Legend Content
Separate cells for each legend category, and then separate rows for each item in that category. This ensures proper formatting. Bad examples of formatting to be avoided are newlines with nested arrays for each item:

- **Key symbols**: 🔑 PK vs 🔑 FK explanation
- **Color legend**: Purple=Fact, Green=Dimension, Light-grey=Mapping, Light-green=DateDimension, Reference=Yellow, Measures=Red
- **Line types**: Solid vs Dashed meanings
- **Cardinality notation**: Chen ERD symbols (— = One, ——— = Many)
- **Relationships**: Each connects from specific FK cell to specific PK cell

## Step 6: Validation Checklist

✓ All tables from `model.bim` are represented  
✓ All relationships from `"relationships"` array are shown  
✓ Primary keys are clearly marked with 🔑 and blue color  
✓ Foreign keys are clearly marked with 🔑 and red color, showing target table  
✓ Each column is in its own cell within a element representing it's parent table (not bundled)  
✓ Each relationship connects from a specific FK cell to a specific PK cell  
✓ Line directionality matches `crossFilteringBehavior`  
✓ Cardinality arrows are correct (one/many)  
✓ Color coding is consistent and meaningful  
✓ Legend is present and complete  
✓ Canvas is large enough to show all elements without overlap  
✓ File naming convention: `[Report's unique numeric identifier]-[Report name]-ERD.drawio` (e.g., `000-CapacityMetrics-ERD.drawio`)

## Step 7: Export and Documentation

### 7.1 Save in folder alongside report / semantic model
- Location: Report's folder (e.g., `010-DatabricksCost/`)
- Filename: `[Report's unique numeric identifier]-[Report name]-ERD.drawio` (e.g., `000-CapacityMetrics-ERD.drawio`) _(do not increment version for updates, Git is used for version tracking)_
- Format: `.drawio` (native draw.io format)

### 7.2 Keep ERD generation instructions updated
- Update `ERD diagram instructions.md` with any process improvement or error-resolution notes, but keep the fixes abstracted to any model, not specific to the model who's ERD is being generated.
- Note some tables that might be hidden in Power BI vs shown in model.bim

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Shapes don't appear | Check `fold="0"` and `page="0"` settings; ensure `dx/dy > 1000` |
| Lines overlap too much | Expand canvas size or reorganize table positions |
| Small text | Increase `fontSize` values (min 8px for readability) |
| Missing relationships | Verify all items from `"relationships"` array are included |
| FK cells not connecting | Ensure connector source/target IDs match exact cell IDs |
| Colors too faint | Verify `swimlaneFillColor` hex codes are correct |

## References

- **Draw.io Documentation**: https://www.drawio.com/doc/
- **Chen Entity-Relationship Model**: https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model
- **Power BI Model Schema**: Power BI semantic model uses TMSL (Tabular Model Scripting Language)
- **Semantic Model File Location**: `[ModelName].SemanticModel/model.bim` (JSON-based Tabular Object Model)

---

**Last Updated**: February 19, 2026  
**Template Version**: 1.0 