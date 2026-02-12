class SelectedFeatureDTO {
  final String featureId;
  final bool isCluster;
  final String sourceID;
  final String type;

  SelectedFeatureDTO({
    required this.featureId,
    required this.isCluster,
    required this.sourceID,
    required this.type,
  });

  factory SelectedFeatureDTO.fromFeature(Map<String, dynamic> feature) =>
      SelectedFeatureDTO(
        featureId: feature['properties']['id'],
        isCluster: feature['properties']['cluster'] as bool,
        sourceID: feature['sourceId']!,
        type: feature['properties']['type'] as String,
      );

  factory SelectedFeatureDTO.empty() => SelectedFeatureDTO(
    featureId: '',
    isCluster: false,
    sourceID: '',
    type: '',
  );
}
