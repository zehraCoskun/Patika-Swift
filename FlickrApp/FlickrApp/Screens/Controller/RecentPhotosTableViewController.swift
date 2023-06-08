//
//  RecentPhotosTableViewController.swift
//  FlickrApp
//
//  Created by Zehra Coşkun on 25.05.2023.
//

import UIKit

class RecentPhotosTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var key = Env.serviceApiKey
    
    private var response: PhotosResponse? {
            didSet {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    private var selectedPhoto : Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController()
        fetchRecentPhotos()
        
    }
    func fetchRecentPhotos(){
        guard let URL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(key)&format=json&nojsoncallback=1&extras=description,owner_name,icon_server,url_n,url_z") else { return }
        let URLRequest = URLRequest(url: URL)
        URLSession.shared.dataTask(with: URLRequest) { Data, URLResponse, Error in
            if let Error = Error {
                print(Error)
                return
            }
            if let Data = Data, let response = try? JSONDecoder().decode(PhotosResponse.self, from: Data) {
                self.response = response
            }
        }.resume()
    }
    func searchPhotos(with text : String){
        guard let URL = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&text=\(text)&format=json&nojsoncallback=1&extras=description,owner_name,icon_server,url_n,url_z") else { return }
        let URLRequest = URLRequest(url: URL)
        URLSession.shared.dataTask(with: URLRequest) { Data, URLResponse, Error in
            if let Error = Error {
                print(Error)
                return
            }
            if let Data = Data, let response = try? JSONDecoder().decode(PhotosResponse.self, from: Data) {
                self.response = response
            }
        }.resume()
    }
    
    func searchController(){
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.photos?.photo?.count ?? .zero
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = response?.photos?.photo?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! PhotoTableViewCell
        cell.ownerNameLabel.text = photo?.ownername
        cell.titleLabel.text = photo?.title
        NetworkManager.shared.fetchImage(with: photo?.urlN) { data in
            cell.photosImageView.image = UIImage(data: data)
        }
        
        if let iconServer = photo?.iconserver,
           let iconFarm = photo?.iconfarm,
           let nsid = photo?.owner,
           NSString(string: iconServer).intValue > 0 {
            NetworkManager.shared.fetchImage(with: "http://farm\(iconFarm).staticflickr.com/\(iconServer)/buddyicons/\(nsid).jpg") { data in
                cell.ownerImageView.image = UIImage(data: data)
            }
        } else {
            NetworkManager.shared.fetchImage(with: "https://www.flickr.com/images/buddyicon.gif") { data in
                cell.ownerImageView.image = UIImage(data: data)
            }
        }
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoto = response?.photos?.photo?[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let viewController = segue.destination as? PhotoDetailsViewController {
            viewController.photo = selectedPhoto
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return}
        if text.count > 1 {
            searchPhotos(with: text)
        }
    }
}

