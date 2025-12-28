class SelectedFeatureDTO {
  final String featureId;
  final bool isCluster;
  final String sourceID;

  SelectedFeatureDTO({
    required this.featureId,
    required this.isCluster,
    required this.sourceID,
  });

  factory SelectedFeatureDTO.empty() =>
      SelectedFeatureDTO(featureId: '', isCluster: false, sourceID: '');
}
