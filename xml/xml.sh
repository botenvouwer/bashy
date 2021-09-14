#!/bin/bash
set -eu
set -o pipefail

# dependencies
# - uuidgen
# - xmlstarlet

# global variables
IDENTIFIER=$1 # example: 14076c36-c26d-2013-ac36-7e65f530188c
GSINVECTOR_REPO_FOLDER=$2
GEOSERVER_WORKSPACE_DIR="$GSINVECTOR_REPO_FOLDER/geoserver-data/data/workspaces"

declare -A SUBGROUPS=(
  [arbeidsmarktregio]=AM
  [arrondissementsgebied]=AR
  [brandweerregio]=BR
  [buurt]=BU
  [coropgebied]=CR
  [coropsubgebied]=CS
  [coropplusgebied]=CP
  [gemeente]=GM
  [ggdregio]=GG
  [grootstedelijke_agglomeratie]=GA
  [jeugdregio]=JZ
  [kamervankoophandelregio]=KK
  [landbouwgebied]=LB
  [landbouwgroep]=LG
  [landsdeel]=LD
  [nuts1]=NE
  [nust2]=NT
  [nuts3]=ND
  [politieregio]=PO
  [provincie]=PV
  [regionaalmeld_coordinatiepunt]=RM
  [regionale_eenheid]=RE
  [regionale_energiestrategie]=RS
  [regioplus_arbeidsmarktregio]=RA
  [ressort]=RT
  [rpagebied]=RP
  [stadsgewest]=SG
  [toeristengebied]=TR
  [toeristengroep]=TG
  [veiligheidsregio]=VR
  [wijk]=WK
  [zorgkantoorregio]=ZK
  [veiligthuisregio]=VT
)
declare -A MAINGROUPS=(
  [arbeidsmarktregio]=arbeidsmarktregio
  [arrondissementsgebied]=arrondissementsgebied
  [brandweerregio]=brandweerregio
  [buurt]=buurt
  [coropgebied]=coropgebied
  [coropsubgebied]=coropsubgebied
  [coropplusgebied]=coropplusgebied
  [gemeente]=gemeente
  [ggdregio]=ggdregio
  [grootstedelijke_agglomeratie]=grootstedelijke_agglomeratie
  [jeugdregio]=jeugdregio
  [kamervankoophandelregio]=kamervankoophandelregio
  [landbouwgebied]=landbouwgebied
  [landbouwgroep]=landbouwgroep
  [landsdeel]=landsdeel
  [nuts1]=nuts1
  [nust2]=nust2
  [nuts3]=nuts3
  [politieregio]=politieregio
  [provincie]=provincie
  [regionaalmeld_coordinatiepunt]=regionaalmeld_coordinatiepunt
  [regionale_eenheid]=regionale_eenheid
  [regionale_energiestrategie]=regionale_energiestrategie
  [regioplus_arbeidsmarktregio]=regioplus_arbeidsmarkt
  [ressort]=ressort
  [rpagebied]=rpagebied
  [stadsgewest]=stadsgewest
  [toeristengebied]=toeristengebied
  [toeristengroep]=toeristengroep
  [veiligheidsregio]=veiligheidsregio
  [veiligthuisregio]=veiligthuisregio
  [wijk]=wijk
  [zorgkantoorregio]=zorgkantoorregio
)

# loop through new_tables.txt
while read -r table_name; do
  # layer variables
  FEATURE_NAME=$table_name
  echo "processing $FEATURE_NAME using identifier $IDENTIFIER"

  # assign values to variables
  IFS='_' read -r -a NAMES <<<$FEATURE_NAME
  GEOM_TYPE=${NAMES[-1]} # labelpoint or gegeneraliseerd
  YEAR=$(echo "${FEATURE_NAME}" | grep -oP '(\d{4})')
  # using a regular expression to get the layer name (match between "cbs_" and "_YEAR")
  LAYER_NAME_SHORT=$(echo "${FEATURE_NAME}" | grep -oP '(?<=cbs_)(.*)(?=_\d{4})')
  SUBGROUP="${SUBGROUPS[$LAYER_NAME_SHORT]}_$YEAR"

  FEATURE_TYPE_UUID="FeatureTypeInfoImpl--$(uuidgen)"
  LAYER_UUID="LayerInfoImpl--$(uuidgen)"
  STYLE=""
  if [ "$GEOM_TYPE" = "labelpoint" ]; then
    STYLE="label"
  elif [ "$GEOM_TYPE" = "gegeneraliseerd" ]; then
    if [ "$LAYER_NAME_SHORT" = "wijk" ]; then
      STYLE="wijken"
    elif [ "$LAYER_NAME_SHORT" = "buurt" ]; then
      STYLE="buurten"
    else
      STYLE="gebiedsindeling"
    fi
  else
    echo "unknown layer type $GEOM_TYPE for feature $FEATURE_NAME"
    exit 1
  fi
STYLE_ID=$(xmlstarlet sel -t -v "style/id" "$GEOSERVER_WORKSPACE_DIR/cbsgebiedsindelingen/styles/cbs_$STYLE.xml")
DATASTORE_ID=$(xmlstarlet sel -t -v "/dataStore/id" "$GEOSERVER_WORKSPACE_DIR/cbsgebiedsindelingen/cbsgebiedsindelingen$YEAR/datastore.xml")
FEATURE_DIR="$GEOSERVER_WORKSPACE_DIR/cbsgebiedsindelingen/cbsgebiedsindelingen$YEAR/$FEATURE_NAME"
LAYERGROUP_DIR="$GEOSERVER_WORKSPACE_DIR/cbsgebiedsindelingen/layergroups"

  # prepare workspace
  mkdir -p $FEATURE_DIR
  cp template/layer/*.xml $FEATURE_DIR

  # feature.xml
  xmlstarlet ed --inplace -u "/featureType/name" -v "$FEATURE_NAME" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -u "/featureType/id" -v "$FEATURE_TYPE_UUID" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -u "/featureType/nativeName" -v "$FEATURE_NAME" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -u "/featureType/title" -v "$FEATURE_NAME" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -u "/featureType/abstract" -v "$FEATURE_NAME" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -a "/featureType/keywords/string" -t elem -n "string" -v "$FEATURE_NAME" "$FEATURE_DIR/featuretype.xml"
  xmlstarlet ed --inplace -u "/featureType/store/id" -v "$DATASTORE_ID" "$FEATURE_DIR/featuretype.xml"

  # layer.xml
  xmlstarlet ed --inplace -u "/layer/name" -v "$FEATURE_NAME" "$FEATURE_DIR/layer.xml"
  xmlstarlet ed --inplace -u "/layer/id" -v "$LAYER_UUID" "$FEATURE_DIR/layer.xml"
  xmlstarlet ed --inplace -u "/layer/defaultStyle/id" -v "$STYLE_ID" "$FEATURE_DIR/layer.xml"
  xmlstarlet ed --inplace -u "/layer/resource/id" -v "$FEATURE_TYPE_UUID" "$FEATURE_DIR/layer.xml"
  xmlstarlet ed --inplace -u "/layer/identifiers/Identifier/identifier" -v "$IDENTIFIER" "$FEATURE_DIR/layer.xml"
  xmlstarlet ed --inplace -u "/layer/path" -v "$LAYER_NAME_SHORT/$SUBGROUP" "$FEATURE_DIR/layer.xml"

  # create layergroup
  SUBGROUP_FILE="$LAYERGROUP_DIR/$SUBGROUP.xml"
  if [ ! -f "$SUBGROUP_FILE" ]; then
    # create new subgroup
    cp template/group/grouplayer.xml "$SUBGROUP_FILE"
    SUBGROUP_UUID="LayerGroupInfoImpl--$(uuidgen)"

    # add subgroup to main group
    GROUP_FILE="$LAYERGROUP_DIR/${MAINGROUPS[$LAYER_NAME_SHORT]}.xml"
    if [ ! -f "$GROUP_FILE" ]; then
      # create new main group
      cp template/group/grouplayer.xml "$GROUP_FILE"
      GROUP_UUID="LayerGroupInfoImpl--$(uuidgen)"
      xmlstarlet ed --inplace -u "/layerGroup/id" -v "$GROUP_UUID" $GROUP_FILE
      xmlstarlet ed --inplace -u "/layerGroup/name" -v "$LAYER_NAME_SHORT" "$GROUP_FILE"
      # insert subnode published for subgroup
      xmlstarlet ed --inplace -s "/layerGroup/publishables" -t elem -n "published" $GROUP_FILE
    else
      # insert new element publisched on top
      xmlstarlet ed --inplace -i "/layerGroup/publishables/published[1]" -t elem -n "published" $GROUP_FILE
    fi
    # add subgroup to main groups's new published element
    xmlstarlet ed --inplace -i "/layerGroup/publishables/published[1]" -t attr -n "type" -v "layerGroup" $GROUP_FILE
    xmlstarlet ed --inplace -s "/layerGroup/publishables/published[1]" -t elem -n "id" $GROUP_FILE
    xmlstarlet ed --inplace -u "/layerGroup/publishables/published[1]/id" -v "$SUBGROUP_UUID" $GROUP_FILE
    xmlstarlet ed --inplace -s "/layerGroup/styles" -t elem -n "style" $GROUP_FILE

    # add layer to subgroup
    xmlstarlet ed --inplace -u "/layerGroup/id" -v "$SUBGROUP_UUID" $SUBGROUP_FILE
    xmlstarlet ed --inplace -u "/layerGroup/name" -v "$SUBGROUP" "$SUBGROUP_FILE"
    xmlstarlet ed --inplace -s "/layerGroup/publishables" -t elem -n "published" $SUBGROUP_FILE
  else
    xmlstarlet ed --inplace -i "/layerGroup/publishables/published[1]" -t elem -n "published" $SUBGROUP_FILE
  fi 
  xmlstarlet ed --inplace -i "/layerGroup/publishables/published[1]" -t attr -n "type" -v "layer" $SUBGROUP_FILE
  xmlstarlet ed --inplace -s "/layerGroup/publishables/published[1]" -t elem -n "id" $SUBGROUP_FILE
  xmlstarlet ed --inplace -u "/layerGroup/publishables/published[1]/id" -v "$LAYER_UUID" $SUBGROUP_FILE
  xmlstarlet ed --inplace -s "/layerGroup/styles" -t elem -n "style" $SUBGROUP_FILE

done <new_tables.txt
echo "done !!!"
