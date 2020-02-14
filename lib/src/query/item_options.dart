class ItemOptions {
  bool expandDropdowns;
  bool getHateoas;
  bool getSha1;
  bool withDevices;
  bool withDisks;
  bool withSoftwares;
  bool withConnections;
  bool withNetworkPorts;
  bool withInfocoms;
  bool withContracts;
  bool withDocuments;
  bool withTickets;
  bool withProblems;
  bool withChanges;
  bool withNotes;
  bool withLogs;

  ItemOptions(
      {this.expandDropdowns = false,
      this.getHateoas = true,
      this.getSha1 = false,
      this.withDevices,
      this.withDisks,
      this.withSoftwares,
      this.withConnections,
      this.withNetworkPorts,
      this.withInfocoms,
      this.withContracts,
      this.withDocuments,
      this.withTickets,
      this.withProblems,
      this.withChanges,
      this.withNotes,
      this.withLogs});

  Map<String, String> toMap() => {
        'expand_dropdowns': expandDropdowns?.toString(),
        'get_hateoas': getHateoas?.toString(),
        'get_sha1': getSha1?.toString(),
        'with_devices': withDevices?.toString(),
        'with_disks': withDisks?.toString(),
        'with_softwares': withSoftwares?.toString(),
        'with_connections': withConnections?.toString(),
        'with_networkports': withNetworkPorts?.toString(),
        'with_infocoms': withInfocoms?.toString(),
        'with_contracts': withContracts?.toString(),
        'with_documents': withDocuments?.toString(),
        'with_tickets': withTickets?.toString(),
        'with_problems': withProblems?.toString(),
        'with_changes': withChanges?.toString(),
        'with_notes': withNotes?.toString(),
        'with_logs': withLogs?.toString()
      }..removeWhere((k, v) => v == null);
}
